function mat = function_mat2col(mat)
%function_mat2col applies mat2gray on all layers of image to normalize them
%   mat = function_mat2col(mat)
%   
%   Inputs
%       mat - matrix of numeric values
% 
%   Outputs
%       mat - normalized image able to put into imshow
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    for n = 1:size(mat,3)
        mat(:,:,n) = mat2gray(mat(:,:,n));
    end
end