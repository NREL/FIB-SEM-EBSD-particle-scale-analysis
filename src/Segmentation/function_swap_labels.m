function mat = function_swap_labels(mat, n1, n2)
%function_swap_labels swaps n1,n in a matrix mat 
%   mat = function_swap_labels(mat, n1, n2)
%   
%   Inputs
%       mat - segmented or integer matrix
%       n1 - value to swap w/ n2
%       n2 - value to swap w/ n1
% 
%   Outputs
%       mat - segmented matrix with n1,n2 swapped
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    was_uint8 = false;    
    if isa(mat, 'uint8')
        was_uint8 = true;
        mat = double(mat); % nan not allowed in uint8 matrix
    end
    
    mat(mat == n1) = NaN;
    mat(mat == n2) = n1;
    mat(isnan(mat)) = n2;
    
    if was_uint8
        mat = uint8(mat);
    end
end