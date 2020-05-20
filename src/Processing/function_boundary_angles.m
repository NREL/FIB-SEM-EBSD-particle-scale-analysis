function grain_props = function_boundary_angles(grain_props)
%function_boundary_angles calculates angles between grain boundaries by
%travesing the grain boundaries
%   grain_props = function_boundary_angles(grain_props) uses the
%       segmentation pattern and labels to compare pixel-pixel at
%       boundaries
%   
%   Inputs
%       grain_props - struct containing grain properties, inclduing
%           matrix/spatial information
% 
%   Outputs
%       grain_props - added information
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL
    
    xyz_cleaned = grain_props.xyz_cleaned;
    
    BW = grain_props.BW;
    grain_labels = grain_props.grain_labels;
    grain_boundaries = grain_props.grain_boundaries;
    
    % CI filtering
    BW(~grain_props.CI) = 0;
    
    % add subfunctions
    deg = [];
    pos_x = [];
    pos_y = [];
    grains_traversed = [];
    angle_counts = 0;
    for n = 1:length(grain_labels)
        curr_grain = grain_labels(n);
        curr_boundaries = grain_boundaries{n};
        grains_traversed = [grains_traversed, curr_grain]; % include traversed before starting becuase particle should not account for itself
        for m = 1:length(curr_boundaries{1}) % for each boundary pixel
            row_loc = curr_boundaries{1}(m,1);
            col_loc = curr_boundaries{1}(m,2);
            
            if BW(row_loc, col_loc) ~= 0
                n1 = squeeze(xyz_cleaned(row_loc, col_loc, :)); % current pixel direction of c-axis

                % conditions
                %   within bounds img ,    boundary not already used            ,              not background  
                if row_loc-1>0 && ~ismember(BW(row_loc-1, col_loc), grains_traversed) && BW(row_loc-1, col_loc) ~= 0  % left-1
                    n2 = squeeze(xyz_cleaned(row_loc-1, col_loc, :));
                    angle_counts = angle_counts + 1;
                    deg(angle_counts) = vec_angl(n1,n2); % acute angle between 2 planes
                    pos_x(angle_counts, :) = [row_loc-.5, row_loc-.5];
                    pos_y(angle_counts, :) = [col_loc-.5, col_loc+.5];
                end

                if row_loc+1<size(BW,1) && ~ismember(BW(row_loc+1, col_loc), grains_traversed) && BW(row_loc+1, col_loc) ~= 0% right-1
                    n2 = squeeze(xyz_cleaned(row_loc+1, col_loc, :));
                    angle_counts = angle_counts + 1;
                    deg(angle_counts) = vec_angl(n1,n2); % acute angle between 2 planes
                    pos_x(angle_counts, :) = [row_loc+.5, row_loc+.5];
                    pos_y(angle_counts, :) = [col_loc-.5, col_loc+.5];
                end

                if col_loc+1<=size(BW,2) && ~ismember(BW(row_loc, col_loc+1), grains_traversed) && BW(row_loc, col_loc+1) ~= 0 % up-2
                    n2 = squeeze(xyz_cleaned(row_loc, col_loc+1, :));
                    angle_counts = angle_counts + 1;
                    deg(angle_counts) = vec_angl(n1,n2); % acute angle between 2 planes
                    pos_x(angle_counts, :) = [row_loc-.5, row_loc+.5];
                    pos_y(angle_counts, :) = [col_loc+.5, col_loc+.5];
                end

                if col_loc-1>0 && ~ismember(BW(row_loc, col_loc-1), grains_traversed) && BW(row_loc, col_loc-1) ~= 0 % down-2
                    n2 = squeeze(xyz_cleaned(row_loc, col_loc-1, :));
                    angle_counts = angle_counts + 1;
                    deg(angle_counts) = vec_angl(n1,n2); % acute angle between 2 planes
                    pos_x(angle_counts, :) = [row_loc-.5, row_loc+.5];
                    pos_y(angle_counts, :) = [col_loc-.5, col_loc-.5];
                end
            end
        end    
    end
    
    grain_props.grain_border_angles = [pos_x, pos_y, deg(:)];
end