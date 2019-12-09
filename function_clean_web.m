function [web, BW_webs_removed] = function_clean_web(seg_map, keep_webs, struct_el)
% function_clean_web separates webbing from segementation map
%   [web, BW_webs_removed] = function_clean_web(seg_map) returns matrix with
%       only webbing, but segmented
%   [web, BW_webs_removed] = function_clean_web(seg_map, keep_webs) returns
%       matrix with only webbings specified by labels in keep_webs. Use
%       function_show_web to see labels
%   [web, BW_webs_removed] = function_clean_web(seg_map, keep_webs, struct_el)
%       applies dilation and erosion to webbings specified by
%       keep_webs using structural element struct_el
%   
%   Inputs
%       seg_map - Specific 2D matrix which has background labeled as 0,
%           webbing as 1, grains as 2
%       keep_webs (optional) - specify which webs should be kept according
%           to numbering of webs made by function_get_web. If unspecified,
%           all webs are kept
%       struct_el (optional) - structured element used to dilate and erode
%           webbing to close any gaps. if unspecfied, dilation/erosion has
%           no effect.
% 
%   Outputs
%       web - segmented webbing cleaned and eroded/dilated
%       BW_webs_removed - cleaned webbing without erosion/dilation
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guidance/Assistance: Donal P. Finagan, NREL
%   Additional assistance from: Francois Usseglio-Viretta, NREL

WEBBING_NUM = 1; % corresponds to webbing
    
    if nargin < 3
        struct_el = strel('disk', 0);
    end
    
	seg_map(seg_map ~= WEBBING_NUM) = 0; % extract webbing from segmentation
    
    BW_iq_web = bwlabel(seg_map,4); % retrive all webs
    
    if nargin < 2
        logical_matrix = logical(ones(size(BW_iq_web)));
    else
        logical_matrix = ismember(BW_iq_web, keep_webs); % anything outside of keepwebs is removed
    end

    BW_iq_web(~logical_matrix) = 0; % only webs wanted, extraneous pixels and small chunks removed
    fig_clean_web = figure; imshow(label2rgb(BW_iq_web))
    
    BW_webs_removed = BW_iq_web;
    
    % Webbing dilation expansion    
	dilated = imdilate(BW_iq_web, struct_el);
	eroded = imerode(dilated, struct_el);

    web = eroded;
end