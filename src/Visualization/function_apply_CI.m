function output_mat = function_apply_CI(matrix, CI_map, replace_value)
%function replace values in matrix wherever in CI_map value = 0
%   item_CI_modified = function_apply_CI(matrix, CI_map, replace_value)
%   takes CI_map, a boolean 2D matrix, and wherever in CI_map the value is
%   0, this location is made to equal 0
%   
%   Inputs
%       matrix - ap
%       CI_map - specifies...
%       replace_value (optional) - 
% 
%   Outputs
%       item_CI_modified - modified matrix with items replaced
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    if nargin < 3
        replace_value = 0;
    end
    for n = 1:size(matrix, 3)
        channel = matrix(:,:,n);
        channel(~CI_map) = replace_value;
        matrix(:,:,n) = channel;
    end
    output_mat = matrix;
end