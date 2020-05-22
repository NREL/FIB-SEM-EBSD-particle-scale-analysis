function img_filtered_noise = function_view_speckle_removed(grain_props)
%function_view_speckle_removed demonstrates cleaning effect on vector data
%   img_filtered_noise = function_view_speckle_removed(grain_props)
%       compares the cleaned image to the original where the original image
%       has only equivalent orientations corrected for.
%   
%   Inputs
%       grain_props - matrix containing xyz_cleaned and xyz_pos fields,
%           which are both representations of a direction using unit
%           vectors
% 
%   Outputs
%       img_filtered_noise - difference in angle between original image
%           representation and outcome is mapped
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    xyz_cleaned = grain_props.xyz_cleaned;
    xyz_pos = grain_props.xyz_pos;

    xyz_angle_discrepancy = zeros(size(xyz_cleaned,1), size(xyz_cleaned,2));
    for n = 1:size(xyz_cleaned)
        for m = 1:size(xyz_cleaned, 2)
            
            n1 = squeeze(xyz_cleaned(n,m,:));
            n2 = squeeze(xyz_pos(n,m,:));
            
            xyz_angle_discrepancy(n,m) = vec_angl(n1, n2);
        end
    end
    xyz_angle_discrepancy = real(xyz_angle_discrepancy);
    img_filtered_noise = xyz_angle_discrepancy./90;
end
