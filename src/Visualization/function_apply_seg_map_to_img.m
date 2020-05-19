function img = function_apply_seg_map_to_img(img, seg_map)
%function_apply_seg_map_to_img make background black according to
%segmentation
%   img = function_apply_seg_map_to_img(img, seg_map) makes an output image
%       img, which is the same as the input img, except blacked out are
%       regions where seg_map = 0
%   
%   Inputs
%       img - image
%       seg_map - labeled segmentation map
% 
%   Outputs
%       img - image
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    if size(img(:,:,1)) ~= size(seg_map(:,:,1)) error('seg_map cannot apply to img, wrong size'); end
    
    for n = 1:size(img,3)
        temp = img(:,:,n);
        temp(seg_map == 0) = 0;
        img(:,:,n) = temp;
    end
end