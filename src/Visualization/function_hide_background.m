function img = function_hide_background(img, seg_map)
%function_hide_background uses segmetation map (BW) to hide non-grains on
%any matrix of the same size
%   img = function_hide_background(img, seg_map)
%   
%   Inputs
%       img - 2D or 3D matrix where sizes of dimensions 1,2 are the same as
%           sizes 1,2 of seg_map
%       seg_map - labeled segmetnation map
% 
%   Outputs
%       img - original img, but regions where label == 0 are made black (by
%           setting value to 0. img is converted to matrix that can be
%           displayed with imshow
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    if size(img(:,:,1)) ~= size(seg_map(:,:,1)); error('seg_map cannot apply to img, wrong size'); end
    
    img = function_mat2col(img); % create image from matrix
    
    % for each layer of image (1 if black and white, 3 if rgb)
    for n = 1:size(img,3)
        temp = img(:,:,n);
        temp(seg_map == 0) = 0;
        img(:,:,n) = temp;
    end
end