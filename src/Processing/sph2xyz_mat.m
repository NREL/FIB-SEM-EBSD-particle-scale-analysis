function xyz_mat = sph2xyz_mat(sph_mat)
%sph2xyz_mat converts m*n*2 th, phi matrix into 3d xyz matrix
%   xyz_mat = sph2xyz_mat(sph_mat) input is a 3D matrix with the
%       3rd dimension 2-deep. sph_mat(:,:,1) is the spatial positioning of
%       the theta values (azimuth) and sph_mat(:,:,2) is the spatial
%       positioning of the phi values (elevation)
%   
%   Inputs
%       sph_mat - 2-deep 3rd dimension 3D matrix with theta values in the
%           first 'layer' and phi values in the second 'layer'
% 
%   Outputs
%       xyz_mat - 3-deep 3rd dimentions 3D matrix with unit vectors of
%           direction represented by xyz_mat(m,n,:). The first layer is x,
%           second y, third z.
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    xyz_mat = zeros(size(sph_mat,1), size(sph_mat,2), 3);
    for n = 1:size(sph_mat, 1)
        for m = 1:size(sph_mat, 2)
            [x_temp, y_temp, z_temp] = sph2cart(sph_mat(n,m,1),sph_mat(n,m,2), 1);
            xyz_mat(n,m,1) = x_temp; xyz_mat(n,m,2) = y_temp; xyz_mat(n,m,3) = z_temp;
        end
    end
end