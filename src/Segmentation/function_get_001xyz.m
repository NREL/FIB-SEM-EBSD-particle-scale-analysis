function [xyz_mat, xyz_pos] = function_get_001xyz(euler_data)
%function_get_001xyz converts EBSD Euler data into a 3D matrix
%containing vectors which represent 001 orientations (the c-axis)
%   [x,y] =  function(a,b) does ....
%   
%   Inputs
%       euler_data - matrix where euler_data(:,:,1)is phi1 (rotation about
%           z), euler_data(:,:,2) is captial phi (rotation about local x),
%           and euler_data(:,:,3) is phi2 (rotation about local z)
% 
%   Outputs
%       xyzz - handle to fig
%       xyz_pos - value
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    rot_mats = cell(size(euler_data,1), size(euler_data,2));
    xyz_mat = zeros(size(euler_data));
    
    for n = 1:size(euler_data,1)
        for m = 1:size(euler_data,2)
            rot_mats{n} = function_rotation_matrix(euler_data(n,m,1), euler_data(n,m,2), euler_data(n,m,3));
            xyz = rot_mats{n}*[0;0;1];
            xyz_mat(n,m,:) = xyz;
        end
    end
    
    xyz_pos = xyz_mat;
    
    for n = 1:size(xyz_pos,1)
        for m = 1:size(xyz_pos,2)
            if xyz_mat(n,m,3) < 0 % if z vector is not in positive hemisphere
                xyz_pos(n,m,:) = -xyz_pos(n,m,:); % flip all signs, rotates -180 deg
            end
        end
    end 
end