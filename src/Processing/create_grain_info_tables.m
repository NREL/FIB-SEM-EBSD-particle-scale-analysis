function [T_pt, ptc_info, T_g, T_ig] = create_grain_info_tables(grain_props)
    pixel_info = [];
    [x,y] = meshgrid(1:size(grain_props.BW,2), 1:size(grain_props.BW,1));
    x_pix = reshape(x, numel(x), 1)-1;
    y_pix = reshape(y, numel(y), 1)-1;
    dist_map = sqrt((x_pix - grain_props.ptc_centroid(1)).^2 + (y_pix - grain_props.ptc_centroid(2)).^2)*grain_props.um_per_pix;

    pixel_info(:,1) = x_pix*grain_props.um_per_pix;
    pixel_info(:,2) = y_pix*grain_props.um_per_pix;
    pixel_info(:,3) = reshape(grain_props.euler(:,:,1), numel(grain_props.euler(:,:,1)), 1);
    pixel_info(:,4) = reshape(grain_props.euler(:,:,2), numel(grain_props.euler(:,:,2)), 1);
    pixel_info(:,5) = reshape(grain_props.euler(:,:,3), numel(grain_props.euler(:,:,3)), 1);
    pixel_info(:,6) = reshape(grain_props.tp_mat_cleaned(:,:,1), numel(grain_props.tp_mat_cleaned(:,:,1)), 1);
    pixel_info(:,7) = reshape(grain_props.tp_mat_cleaned(:,:,2), numel(grain_props.tp_mat_cleaned(:,:,2)), 1);
    pixel_info(:,8) = reshape(grain_props.ptc_map, numel(grain_props.ptc_map), 1);
    pixel_info(:,9) = reshape(grain_props.BW, numel(grain_props.BW), 1);
    pixel_info(:,10) = reshape(grain_props.BW_intragrain, numel(grain_props.BW_intragrain), 1);
    pixel_info(:,11) = reshape(grain_props.ptc_edge_map*grain_props.um_per_pix, numel(grain_props.ptc_edge_map),1); % distance from edge
    pixel_info(:,12) = reshape(dist_map, numel(dist_map), 1); % distance from centroid

    T_pt = array2table(pixel_info);
    T_pt.Properties.VariableNames(1:12) = {'x_um', 'y_um', 'Euler1', 'Euler2', 'Euler3', 'Theta',...
        'Phi', 'IsParticle', 'GrainLabel', 'IntragrainLabel', 'DistanceFromEdge_um', 'DistanceFromCentroid_um'};

    % particle table
    ptc_info = {};
    ptc_info{1,1} = 'centroid_x_pix';       ptc_info{1,2} = grain_props.ptc_centroid(1); 
    ptc_info{2,1} = 'centroid_y_pix';       ptc_info{2,2} = grain_props.ptc_centroid(2); 
    ptc_info{3,1} = 'area_pix';             ptc_info{3,2} = grain_props.ptc_area;
    ptc_info{4,1} = 'um per pixel';         ptc_info{4,2} = grain_props.um_per_pix;
    ptc_info{5,1} = 'number of grains';     ptc_info{5,2} = numel(grain_props.grain_labels);
    ptc_info{6,1} ='number of intragrains'; ptc_info{6,2} = numel(grain_props.intragrain_labels);

    % grain table
    grain_info = [];
    grain_info(:,1) = grain_props.grain_labels(:);
    grain_info(:,2) = grain_props.grain_centroids(:,1);
    grain_info(:,3) = grain_props.grain_centroids(:,2);
    grain_info(:,4) = grain_props.grain_areas(:);
    grain_info(:,5) = grain_props.grain_circularities(:);
    grain_info(:,6) = grain_props.grain_perimeter(:);
    grain_info(:,7) = grain_props.grain_eccentricities(:);
    grain_info(:,8) = grain_props.grain_dist(:); % distance from edge

    T_g = array2table(grain_info);
    T_g.Properties.VariableNames(1:8) = {'Grain', 'GrainCentroidsX_pix', 'GrainCentroidsY_pix',...
        'GrainArea_pix', 'GrainCircularity_pix', 'GrainPerimeter_pix',...
        'GrainEccentricities_pix', 'GrainCentroidDistanceFromEdge_pix'};

    % intragrain table
    intragrain_info = [];
    for n = 1:length(grain_props.grain_labels)
        m = [];

        iglbls = grain_props.orientation_frequencies{n}(:,1); % intra_grain #
        iglbls(iglbls > numel(grain_props.intragrain_labels)) = [];

        m(:,1) = iglbls; % intra_grain #
        m(:,2) = n*ones(size(m,1),1); % grain #
        m(:,3) = grain_props.intragrain_centroids(m(:,1), 1); % centroid-x
        m(:,4) = grain_props.intragrain_centroids(m(:,1), 2); % centroid-x
        m(:,5) = grain_props.intragrain_areas(m(:,1));
        m(:,6) = grain_props.intragrain_circularities(m(:,1));
        m(:,7) = grain_props.intragrain_perimeter(m(:,1));
        m(:,8) = grain_props.intragrain_eccentricities(m(:,1));

        intragrain_info = cat(1, intragrain_info, m);    
    end

    T_ig = array2table(intragrain_info);
    T_ig.Properties.VariableNames(1:8) = {'Intragrain', 'Grain', 'IntragrainCentroidsX_pix', 'IintragrainCentroidsY_pix',...
        'IntragrainArea_pix', 'IntragrainCircularity_pix', 'IntragrainPerimeter_pix', 'IntragrainEccentricities_pix'};
end