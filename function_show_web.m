function [fig, lbls2include] = function_show_web(seg_map, varargin)
% function_show_web separates webbing from segementation map
%   [web, f1] = function_show_web(seg_map)
%   [web, f1] = function_show_web(seg_map, nums) returns only the
%       webbing with every disconnected webbing labeled wih an integer.
%   
%   Inputs
%       seg_map - Specific 2D matrix which has background labeled as 0, and
%           grains or the webbing labeled as eitehr 1,2
%       nums (optional) - the number of webs to display based on largest to
%           smallest 
%       
% 
%   Outputs
%       web - structures overlayed onto '0' background
%       f1 - labeled map of webbing to make choice on
%           function_clean_web
%       lbls2include - labels corresponding to largest webbings by area.
%           The number of webbings chosen is given by the nums parameter.
%           This can be fed directly into function_clean_webs if no updates
%           are to be made.
%
%    Optional parameters
%       'ShowLabels' | true/false - default true, if set to false will not
%           show labels ontop of webbing
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guidance/Inspiration: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

WEBBING_NUM = 1; % corresponds to webbing

    default_show_labels = true;
    default_nums = [];
    
    p = inputParser;
    addRequired(p, 'seg_map');
    addOptional(p, 'nums', default_nums);
    addParameter(p, 'ShowLabels', default_show_labels); 
    parse(p,seg_map,varargin{:});
    
    seg_map = p.Results.seg_map;
    nums = p.Results.nums;
    show_labels = p.Results.ShowLabels;

	seg_map(seg_map ~= WEBBING_NUM) = 0;
    
    BW_iq_web = bwlabel(seg_map,4); % retrive all webs
    
    lbls = unique(BW_iq_web); lbls(lbls == 0) = []; % note all values are here - no risk of skipped values
    rp = regionprops(BW_iq_web, 'Area');
    areas = cat(1,rp.Area);
    
    lbls_sort_by_area = sortrows([lbls(:), areas], 2, 'descend');
    
    if isempty(nums)
        lbls2include = lbls;
    else
        lbls2include = lbls_sort_by_area(1:nums, 1);
    end
    
    BW_iq_web(~ismember(BW_iq_web, lbls2include)) = 0;   
    if show_labels
        fig = function_bwshowlabels(BW_iq_web, 'first');
    else
        fig = figure; imshow(label2rgb(BW_iq_web));
    end
end