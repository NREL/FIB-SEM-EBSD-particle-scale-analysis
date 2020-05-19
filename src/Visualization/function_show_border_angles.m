function fig = function_show_border_angles(grain_props, deg_mat)
%function_show_border_angles creates image which colors boundaries with
%respect to the inter/intragrain boundary
%   fig = function_show_border_angles(grain_props, deg_mat)
%   
%   Inputs
%       grain_props - grain_props matrix
%       deg_mat - 5 column vector which has [xpos1, xpos2, ypos1, ypos2,
%           deg]. created in function_intragrain_boundary_angles_raster
% 
%   Outputs
%       fig - fig handle to colormap
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    pos_x_intragrain = deg_mat(:,1:2);
    pos_y_intragrain = deg_mat(:,3:4);
    deg_intragrain = deg_mat(:,5);
    
    xyz_cleaned_image_ci = function_mat2col(grain_props.xyz_cleaned); xyz_cleaned_image_ci = function_apply_CI(xyz_cleaned_image_ci, grain_props.CI, 0);
    xyz_cleaned_image_ci = rgb2gray(xyz_cleaned_image_ci);
    xyz_cleaned_image_ci = cat(3, xyz_cleaned_image_ci, xyz_cleaned_image_ci, xyz_cleaned_image_ci);
    
    deg_valszz = unique(deg_intragrain(:,1)); % sorted unique angles
    colmapzz = hot(length(deg_valszz)); % change color type here

    for n = 1:length(deg_intragrain)
        [~, col_idx] = min(abs(deg_valszz - deg_intragrain(n)));
        c_datazz(n,:) = colmapzz(col_idx, :);
    end
    
    xyz_cleaned_image_ci = function_apply_seg_map_to_img(xyz_cleaned_image_ci, grain_props.BW);
    
    % rgb_euler_meaned
    deg22 = deg_intragrain; deg22(deg_intragrain(:,1)  < 0,:) = [];
    pos_y22 = pos_y_intragrain; pos_y22(deg_intragrain(:,1)  < 0,:) = [];
    pos_x22 = pos_x_intragrain; pos_x22(deg_intragrain(:,1)  < 0,:) = [];
    c_data22 = c_datazz; c_data22(deg_intragrain(:,1)  < 0,:) = [];

    fig = figure; fig.Color = 'white'; fig.Units = 'inches'; 
    
    imshow(xyz_cleaned_image_ci); hold on;
    scatter(mean(pos_y22,2), mean(pos_x22,2),1.5,c_data22, 'filled')
    colormap(colmapzz);% c_borders = colorbar; 

%     angles_for_colmap = round(linspace(min(deg_intragrain(:,1)), max(deg_intragrain(:,1)), length(c_borders.TickLabels)));
    
    fig.Position(3) = 2.75; fig.Position(4) = 2.75;
    
    
%     c_borders.TickLabels 
%     c_borders.TickLabels = arrayfun(@(x)cellstr(num2str(x)), linspace(0,90,length(c_borders.TickLabels)));
%     c_borders.Label.String = 'Angle Between Planes (deg)';
%     c_borders.FontSize = 12;
%     
%     c_borders
    
    
end
