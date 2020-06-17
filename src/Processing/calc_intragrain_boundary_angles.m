function grain_props = calc_intragrain_boundary_angles(grain_props)
%calc_intragrain_boundary_angles rasters across intragrain
%segmented image to calculate all pixel-pixel misorientations
%   grain_props = calc_intragrain_boundary_angles(grain_props)
%   
%   Inputs
%       grain_props - grain properties
% 
%   Outputs
%       grain_props - updated wtih intragrain boundary information as
%           matrix
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

BW_grain = grain_props.BW; % grain-level used to focus on individual grains
    grain_labels = unique(BW_grain); grain_labels(grain_labels == 0) = [];    
    
    BW_intragrain = grain_props.BW_intragrain; % needed to extract intragrain labels and respective boundaries
%     intragrain_boundaries = grain_props.intragrain_boundaries; % intragrain boundaries
    
    xyz_cleaned = grain_props.xyz_cleaned; % orientation data
    
    % CI filtering
    BW_grain(~grain_props.CI) = 0;
    BW_intragrain(~grain_props.CI) = 0;
    
    deg = [];
    pos_x = [];
    pos_y = [];
    angle_counts = 0;
    
    % left-right
    for n = 1:size(BW_grain,1) % row
        for m = 1:size(BW_grain,2) % column (along x direction)
            if m < size(BW_grain,2) % not last pixel in row
                if BW_grain(n,m) == BW_grain(n,m+1) && BW_intragrain(n,m) ~= BW_intragrain(n,m+1) % on some sort of boundary
                    n1 = squeeze(xyz_cleaned(n,m,:));
                    n2 = squeeze(xyz_cleaned(n,m+1,:));
                    angle_counts = angle_counts + 1;
                    deg(angle_counts) = vec_angl(n1,n2); % acute angle between 2 planes
                    pos_y(angle_counts, :) = [m+.5, m+.5];
                    pos_x(angle_counts, :) = [n-.5, n+.5];
                end
            end
        end
    end    
    
    for n = 1:size(BW_grain,2) % column
        for m = 1:size(BW_grain,1) % row (along y direction)
            if m < size(BW_grain,1) % not last pixel in row
                if BW_grain(m,n) == BW_grain(m+1,n) && BW_intragrain(m,n) ~= BW_intragrain(m+1,n) % on some sort of boundary
                    n1 = squeeze(xyz_cleaned(m,n,:));
                    n2 = squeeze(xyz_cleaned(m+1,n,:));
                    angle_counts = angle_counts + 1;
                    deg(angle_counts) = vec_angl(n1,n2); % acute angle between 2 planes
                    pos_y(angle_counts, :) = [n-.5, n+.5];
                    pos_x(angle_counts, :) = [m+.5, m+.5];
                end
            end
        end
    end    
    
    grain_props.intragrain_border_angles = [pos_x, pos_y, deg(:)]; % for plotting
end