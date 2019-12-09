function tp_mat = function_xyzmat2sphmat(xyz_mat)
%function_xyzmat2sphmat converts m*n*3 x,y,z matrix into 3D th,phi matrix
%   tp_mat = function_xyzmat2sphmat(xyz_mat) input is a 3D matrix with the
%       3rd dimension 3-deep. xyz_mat(:,:,1) is the spatial positioning of
%       the x values (azimuth) and xyz_mat(:,:,2) of the y, xyz_mat(:,:,3)
%       of the z
%   
%   Inputs
%       xyz_mat - 3-deep 3rd dimension 3D matrix with (m,n,:) = [x,y,z].
%           x,y,z represent a direction via unit vector 
% 
%   Outputs
%       tp_mat - 2-deep 3rd dimentions 3D matrix theta (azimuth) and phi
%           (elevation)
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    tp_mat = zeros(size(xyz_mat,1), size(xyz_mat,2), 2);
    for n = 1:size(xyz_mat, 1)
        for m = 1:size(xyz_mat, 2)
            [theta_temp, phi_temp] = cart2sph(xyz_mat(n,m,1),xyz_mat(n,m,2),xyz_mat(n,m,3));
            tp_mat(n,m,1) = theta_temp; tp_mat(n,m,2) = phi_temp;
        end
    end
end