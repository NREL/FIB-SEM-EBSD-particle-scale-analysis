function [fig, data, center_vertex, frames] = function_hist3D_xyz(xyz, varargin)
%function_hist3D_xyz 3D histogram visualization
%   [fig, D, CV] =  function_hist3D_xyz(xyz, shape_type, subdiv) 
%   Creates a spherical histogram by binning vectors directed from a
%   central point into approximate equal-area surfaces of a sphere 
%   (approximated using a platonic solid of choice). Platonic solid shapes
%   are calculated using 'platonic_solid.m' written by Kevin Mattheus
%   Moerman. Bins of finer resolution can be created by subdividing the
%   platonic solid surfaces into equal surface area triangles. Default
%   platonic solid is the icosahedron, due to equally sized triangles
%   across its surface.
%   
%   Inputs
%       xyz - matrix where rows correspond to [x,y,z] values which
%           are unit vectors corresponding to a specific direciton for a
%           given entitiy. Expressing unit orientaitons useful for matrix
%           operations. 
%      
%   Outputs
%       fig - handle to figure of 3D histogram
%       data - column matrix of [bin#, count of vectors in bin, normalized
%           count, theta, phi]. Theta and phi point to centroid of bin.
%       center_vertex - unit vectors from origin pointing to center of each
%           bin
%       frames - cell array of 'frames' for rotating histogram. 
%           'ProduceVideo' parameter must be set to true, else returns {}.
%           FRM can be easily written to video using VideoWriter feature.
%           3D histogram rotates about z-axis (blue).
%   
%    Optional parameters
%       'Representation' | 'cube', 'icosahedron', 'dodecahedron' -
%           specifies platonic solid base shape
%       'Subdivision' | integer n > 0 - increases number of bins by
%           dividing surface shapes n times. Non-triangular bins are
%           divided into triangles. Triangular bins are divided into 4
%           triangles using loop subdivision. Due to compounding nature, 4+
%           subdivisions will slow performance significantly.
%       'ColorFaces' | true/false - applies colormap to faces of 3D histogram% 
%       'ShowLines' | true/false - plots indiviudal lines
%       'PlotMethod' | 'expansion' (default), 'extrusion', 'lines' -
%           multiple ways to visualize data
%       'BaseLine' | double from 0-1 - shifts basline from origin out
%           radially
%       'FaceVer' | array of integers in range [1, n], where n is number of
%           bins. Used to verify whether lines lie within created bin%           
%       'ProduceVideo' | true/false
%       'FilterFrequency' |  n = double from 0-1 - allows filtering of
%           frequencies > n
%       'Normalization' | integer - scales extrusion.
% 
%   Note: the binning accuracy has not been rigorously tested yet.
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Inspiration: Donal P. Finagan, NREL
%   Additional Assitance:  Francois Usseglio-Viretta, NREL
    
    %% Default Values
    default_show_lines = false;
    default_color_faces = false;
    default_plot_method = 'expansion'; % 'extrusion', 'lines'
    default_baseline = 0;
    default_face_verification = [];
    default_produce_video = false;
    default_filter_frequency = Inf;
    default_representation = 'icosahedron';
    default_subdivision = 1;
    default_normalization = NaN;
    
    p = inputParser;
    addRequired(p, 'xyz');
    addParameter(p, 'ColorFaces', default_color_faces); 
    addParameter(p, 'ShowLines', default_show_lines);
    addParameter(p, 'PlotMethod', default_plot_method);
    addParameter(p, 'BaseLine', default_baseline);
    addParameter(p, 'FaceVer', default_face_verification);
    addParameter(p, 'ProduceVideo', default_produce_video);
    addParameter(p, 'FilterFrequency', default_filter_frequency);
    addParameter(p, 'Representation', default_representation);
    addParameter(p, 'Subdivision', default_subdivision);
    addParameter(p, 'Normalization', default_normalization);
    parse(p,xyz,varargin{:});
    
    xyz = p.Results.xyz;
    show_lines = p.Results.ShowLines;
    color_faces = p.Results.ColorFaces;
    plot_method = p.Results.PlotMethod;
    base_line = p.Results.BaseLine;
    face_ver = p.Results.FaceVer;
    produce_video = p.Results.ProduceVideo;
    filter_frequency = p.Results.FilterFrequency;
    representation = p.Results.Representation;
    subdivisions = p.Results.Subdivision;
    normalization = p.Results.Normalization;
    
    %% Original geometry
    is_subdivided = false;
    if subdivisions > 0
        is_subdivided = true;
    end
    
    if strcmpi(representation, 'icosahedron')
        shape_type = 4;
    elseif strcmpi(representation, 'cube')
        shape_type = 2;
    elseif strcmpi(representation, 'dodecahedron')
        shape_type = 5;
    else
        error([representation ' not supported shape representation']);
    end
    
    [vertices, faces] = platonic_solid(shape_type,1); % create platonic solid of radius 1
    og_face_verticies = [3, 4, 3, 3, 5];
    og_num_v_per_f = og_face_verticies(shape_type);
    
    %% Subdivision algorithm - Loop Subdivision
    % Center vertex added if non-triangluar geometry
    % Loop subdivision with triangular geometry
    
    midpoint_tracking = [];
    midpoint_idx = [];
    num_v_per_f = og_num_v_per_f;
    for n = 1:subdivisions
        if num_v_per_f > 3 % Non-triangular, add center point to create triangles
            new_vertices = vertices;
            new_faces = [];    
            for m = 1:length(faces) % per old face
                c_vs = vertices(faces(m,:)', :); % current vertices
%                 v_combos = combnk(faces(m,:), 2); % all possible index
%                   pairs - not included in std Matlab
                v_combos = combpairs(faces(m,:));
                
                distances = zeros(length(v_combos), 1);
                for k = 1:length(v_combos) % find distances between all pairs
                    distances(k) = pdist2(vertices(v_combos(k,1), :),  vertices(v_combos(k,2), :)); % distance for each of the possible comobos
                end
                [~, sort_idxs] = sort(distances); % sort to get smallest distances first, this will make the pairs
                combo_v_to_use = sort_idxs(1:num_v_per_f); % idxs correspond to all correct index pairs
                idx_pairs = v_combos(combo_v_to_use(:), :); % idx pairs correspond to original verticies matrix, thus triangles can now be made, once

                new_center = sum(c_vs)/size(c_vs, 1); % center by center of mass

                [th_temp, phi_temp, ~] = cart2sph(new_center(1), new_center(2), new_center(3)); % get angle
                [new_center(1), new_center(2), new_center(3)] = sph2cart(th_temp, phi_temp, 1); % make radius=1

                new_vertices(end+1, :) = new_center; % add to vertices list
                vtx_number_new = length(new_vertices); % assign new vertex number, for dodecahedron should be 12 new

                new_faces = cat(1, new_faces, [idx_pairs, vtx_number_new*ones(length(idx_pairs), 1)]); % all new faces!
            end
            num_v_per_f = 3;
            faces = new_faces;
            vertices = new_vertices;
        else
            new_vertices = vertices;
            new_faces = [];
            for m = 1:length(faces) % per face, subdivide into 4 triangles (loop subdivision) 
                c_v_idxs = faces(m,:); % current vertex indices
                c_v_idxs_mids = [];
                
%                 v_combos = combnk(faces(m,:), 2); % all possible index pairs - should only be 3
                v_combos = combpairs(faces(m,:));
                for k = 1:length(v_combos) % loop finds or creates midpoints
                    if ~isempty(midpoint_tracking) && any(ismember([v_combos(k,1), v_combos(k,2); v_combos(k,2), v_combos(k,1)], midpoint_tracking, 'rows')) % midpoint already created?
                        
                        [~, idx_in_length] = ismember([v_combos(k,1), v_combos(k,2); v_combos(k,2), v_combos(k,1)], midpoint_tracking, 'rows'); % get midpoint trackign index, correponds to midpoint indx
                        idx_temp = find(idx_in_length);
                        c_v_idxs_mids(end+1) = midpoint_idx(idx_in_length(idx_temp)); % midpoint idx corresponed to vertex of interest
                    else % create vertex and bump to radius
                        v1 = new_vertices(v_combos(k,1), :); % get position of vertex 1
                        v2 = new_vertices(v_combos(k,2), :); % get position of vertex 2
                        v3 = sum([v1;v2])/2; % mean to get 
                        
                        [th_temp, phi_temp, ~] = cart2sph(v3(1), v3(2), v3(3)); % get angle
                        [v3(1), v3(2), v3(3)] = sph2cart(th_temp, phi_temp, 1); % make radius=1
                        
                        new_vertices(end+1,:) = v3; % add new vertex
                        c_v_idxs_mids(end+1) = length(new_vertices); % new index for new vertex
                        midpoint_tracking(end+1, :) = [v_combos(k,1), v_combos(k,2)];
                        midpoint_idx(end+1) = length(new_vertices);
                    end
                end
                for k = 1:length(c_v_idxs)
                    distances = [];
                    for j = 1:length(c_v_idxs_mids)
                        distances(j) = pdist2(new_vertices(c_v_idxs(k),:), new_vertices(c_v_idxs_mids(j),:)); 
                    end
                    [~, og_vert_idxs] = sort(distances);
                    new_faces(end+1,:) = [c_v_idxs(k), c_v_idxs_mids(og_vert_idxs(1)), c_v_idxs_mids(og_vert_idxs(2))]; % specific vertex and 2 nearest points are new triangle
                end
                new_faces(end+1,:) = c_v_idxs_mids; % all vertices form one triangle 
            end
            vertices = new_vertices;
            faces = new_faces;
        end
    end
    
    %% Center expand to radius = 1
    center_vertex = zeros(length(faces), 3);
    angle_th = zeros(length(faces),1);
    angle_phi = zeros(length(faces),1);
    for n = 1:length(faces) % for each face
        face_vtx_indices = faces(n,:); % save face vertex indices here    
        collected_vertices = vertices(face_vtx_indices(:), :); % collect vertices using index
        center_vertex(n,:) = sum(collected_vertices)/size(collected_vertices, 1); % average x,y,z for center of mass
        [th_temp, phi_temp, ~] = cart2sph(center_vertex(n,1), center_vertex(n,2), center_vertex(n,3)); % get angle
        [center_vertex(n,1), center_vertex(n,2), center_vertex(n,3)] = sph2cart(th_temp, phi_temp, 1); % make radius=1
        angle_th(n) = th_temp;
        angle_phi(n) = phi_temp;
    end
    
    %% Data binning
    % distance of each point to center of each face for binning purposes
    counts = zeros(length(faces), 1); % to store frequency per face, m corresponds to face index
    
    f = figure;
    
    c_map = zeros(length(faces), 3);    
    for n = 1:length(face_ver)
        select_face = face_ver(n);
        c_map(select_face,:) = 1; % select face is white (color code?)
    end    
    
    for n = 1:length(xyz) % for each xyz values
        distm = zeros(length(faces), 1);
        for m = 1:length(faces) % for each faces, get distances
            distm(m) = pdist2(xyz(n,:), center_vertex(m,:)); % per face, get distance of given point to all centers
        end
        [~, idx] = min(distm); % value with minimum distance gets binned
        counts(idx) = counts(idx) + 1; % frequency of vector pointing to space
        
        if show_lines
            plot3([0 xyz(n,1)], [0 xyz(n,2)], [0 xyz(n,3)], 'Color', c_map(idx,:), 'LineWidth', 2) % plot individual lines
            hold on
        end
    end
    
    %% Plot 
    unnormalized_counts = counts; % to save data
    
    % Normalization affects length of radial bins
    if isnan(normalization)
        counts = counts/max(counts);
    else
        max(counts)
        counts = counts/normalization;
    end
    
    counts(counts > filter_frequency) = 0; % filtering for frequency here
    
    all_faces = [];
    all_verticies = [];
    all_faces_to_origin = [];
    all_vtx_colors = [];

    for n = 1:length(counts) % per face on geometry
        
        face_num(n) = n;
        face_freq(n) = counts(n);
        cc = counts(n);

        if strcmp(plot_method, 'expansion') % expand radius of each bin to touch %% counts(n) ~= 0 && 
            face_vtx_indices =  faces(n,:);
            collected_vertices = vertices(face_vtx_indices(:), :); % per face
            
            for m = 1:length(collected_vertices)
                [TH, PHI, R] = cart2sph(collected_vertices(m,1), collected_vertices(m,2), collected_vertices(m,3));
                R = R * counts(n); % adjust radius 
                [collected_vertices(m,1), collected_vertices(m,2), collected_vertices(m,3)] = sph2cart(TH, PHI, R);
            end
            collected_vertices((size(collected_vertices,1) + 1),:) = 0; % represents the origin
            
            if shape_type == 4 || is_subdivided
                face_verticies = [1,2,3];
                face_to_origin_faces = [4,1,2; 4,2,3; 4,3,1];
                vtx_colors = [cc;cc;cc;0];

                all_faces = cat(1, all_faces, face_verticies+4*(n-1)); % 4n-4
                all_verticies = cat(1, all_verticies, collected_vertices); % unmodified
                all_faces_to_origin = cat(1, all_faces_to_origin, face_to_origin_faces+4*(n-1));

                all_vtx_colors = cat(1,all_vtx_colors,vtx_colors);
            elseif shape_type == 5
                face_verticies = [1,2,3,4,5];
                face_to_origin_faces = [6,1,2; 6,2,3; 6,3,4; 6,4,5; 6,5,1];
                vtx_colors = [cc;cc;cc;cc;cc;0];

                all_faces = cat(1, all_faces, face_verticies+6*(n-1)); % 4n-4
                all_verticies = cat(1, all_verticies, collected_vertices); % unmodified
                all_faces_to_origin = cat(1, all_faces_to_origin, face_to_origin_faces+6*(n-1));

                all_vtx_colors = cat(1,all_vtx_colors,vtx_colors);
            elseif shape_type == 2
                face_verticies = [1,2,3,4];
                face_to_origin_faces = [5,1,2; 5,2,3; 5,3,4; 5,4,1];
                vtx_colors = [cc;cc;cc;cc;0];

                all_faces = cat(1, all_faces, face_verticies+5*(n-1)); % 4n-4
                all_verticies = cat(1, all_verticies, collected_vertices); % unmodified
                all_faces_to_origin = cat(1, all_faces_to_origin, face_to_origin_faces+5*(n-1));

                all_vtx_colors = cat(1,all_vtx_colors,vtx_colors);
            else
                error('shape type not tested')
            end
        
        elseif strcmp(plot_method, 'extrusion') % extrude from baseline  % counts(n) ~= 0 &&             
            if base_line == 0
                base_line = 1;
            end
                        
            face_vtx_indices =  faces(n,:);
            collected_vertices = vertices(face_vtx_indices(:), :); % per face
            center_vertex_direction = center_vertex(n,:); % center vertex has radius = 1
            
            % adjust baseline            
            for m = 1:length(collected_vertices)
                [TH, PHI, ~] = cart2sph(collected_vertices(m,1), collected_vertices(m,2), collected_vertices(m,3));
                [collected_vertices(m,1), collected_vertices(m,2), collected_vertices(m,3)] = sph2cart(TH, PHI, base_line);
            end
            
            for m = 1:length(collected_vertices)
                collected_vertices(end+1,:) =  collected_vertices(m,:) + center_vertex_direction*counts(n);
            end
                        
            if shape_type == 4 || is_subdivided % triangle
                face_verticies = [4,5,6]; % extruded
                side_faces = [1,2,5,4; 2,3,6,5; 3,1,4,6]; % side walls
                vtx_colors = [0;0;0;cc;cc;cc];

                all_faces = cat(1, all_faces, face_verticies+6*(n-1));
                all_verticies = cat(1, all_verticies, collected_vertices); % unmodified
                all_faces_to_origin = cat(1, all_faces_to_origin, side_faces+6*(n-1));
                
                all_vtx_colors = cat(1,all_vtx_colors,vtx_colors);
            elseif shape_type == 5 % dodeca
                face_verticies = [6,7,8,9,10];
                side_faces = [1,2,7,6; 2,3,8,7; 3,4,9,8; 4,5,10,9; 5,1,6,10];
                vtx_colors = [0;0;0;0;0;cc;cc;cc;cc;cc];

                all_faces = cat(1, all_faces, face_verticies+10*(n-1));
                all_verticies = cat(1, all_verticies, collected_vertices); % unmodified
                all_faces_to_origin = cat(1, all_faces_to_origin, side_faces+10*(n-1));

                all_vtx_colors = cat(1,all_vtx_colors,vtx_colors);
            elseif shape_type == 2 % square
                face_verticies = [5,6,7,8];
                side_faces = [1,2,6,5; 2,3,7,6; 3,4,8,7; 4,1,5,8];
                vtx_colors = [0;0;0;0;cc;cc;cc;cc];

                all_faces = cat(1, all_faces, face_verticies+8*(n-1));
                all_verticies = cat(1, all_verticies, collected_vertices); % unmodified
                all_faces_to_origin = cat(1, all_faces_to_origin, side_faces+8*(n-1));

                all_vtx_colors = cat(1,all_vtx_colors,vtx_colors);
            else
                error('shape type not tested')
            end

        elseif strcmp(plot_method, 'lines')
            face_vtx_indices =  faces(n,:);
            collected_vertices = vertices(face_vtx_indices(:), :); % per face
            cntr = center_vertex(n,:)*counts(n); % center vertex has radius = 1

            hold on;
            plot3([0 cntr(1)], [0 cntr(2)], [0 cntr(3)], 'Color', [0.5, 0.5, 0.5], 'LineWidth', 3)
        else
            error('Method unknown')
        end
    end

    if color_faces
        p1 = patch('Faces', all_faces, 'Vertices', all_verticies, 'FaceColor','interp', 'FaceVertexCData', all_vtx_colors, 'FaceAlpha',1,'EdgeColor','k','LineWidth',2); axis equal; grid on; hold on; view(3); axis off;
        p2 = patch('Faces', all_faces_to_origin, 'Vertices', all_verticies, 'FaceColor', 'interp','FaceVertexCData', all_vtx_colors,'FaceAlpha',1,'EdgeColor','k','LineWidth',1); axis equal; grid on; hold on; view(3); axis off;
    else
        p1 = patch('Faces', all_faces,'Vertices',all_verticies,'FaceColor','r','FaceAlpha',1,'EdgeColor','k','LineWidth',2); axis equal; grid on; hold on; view(3); axis off;
        p2 = patch('Faces', all_faces_to_origin,'Vertices',all_verticies,'FaceColor',[0.6 0 0],'FaceAlpha',1,'EdgeColor','k','LineWidth',2); axis equal; grid on; hold on; view(3); axis off;
    end

    % axes
    plot3([0 1.5], [0 0], [0 0], 'k', 'Linewidth', 6)
    plot3([0 0], [0 1.5], [0 0], 'g', 'Linewidth', 6)
    plot3([0 0], [0 0], [0 1.5], 'b', 'Linewidth', 6)
    xlim([-1.5 1.5]); ylim([-1.5 1.5]); zlim([-1.5 1.5]);
    f.Color = 'white';
    
    lgt = camlight; lighting gouraud; material dull;

    %% Create Video
    frames = {};
    if produce_video
        a = gca;
        frames = cell(360,1);
        for n = 1:360
            a.View(1) = a.View(1) + 2;
            frames{n} = getframe(gcf);
        end
    end
    
    %% Save data
    fig = f; 
    data = [face_num(:), unnormalized_counts, face_freq(:), angle_th(:), angle_phi(:)];    
    
end

%% Supporting Functions
function d = pdist2(p1, p2)
    d = sqrt(sum((p2-p1).^2));
end

% v is vector
function comb = combpairs(v)
% replaces combnk(v,2) to avoid dependancy on statistics toolbox
    v_len = length(v);
    comb = zeros(sum(1:(v_len-1)),2);
    ct = 0;
    for n = 1:(v_len-1)
        for m = (n+1):v_len
            ct = ct + 1;
            comb(ct, :) = [v(n), v(m)];
        end
    end
end