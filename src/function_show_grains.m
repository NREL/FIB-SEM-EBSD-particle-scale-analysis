function [fig, lbls2include] = function_show_grains(seg_map, varargin)
%function_get_grains shows grains and their labels
%   [grains, fig_grains, lbls] = function_get_grains(seg_map)
%       displays all grains with labels
%   [grains, fig_grains, lbls] = function_get_grains(seg_map, area_thrshld)
%       uses area threshold above to remove grains below size threshold. 
%   
%   Inputs
%       seg_map - original segmentation map
%       area_thrshld - area threshold in pixels^2. Segmentation groups <
%           area are not inlcuded in lbls2include nor do they show up on
%           the figure
% 
%   Outputs
%       fig - handle to figure which shows labels for all regions
%       lbls2include - based on area_threshold, incldues the labels for all
%           regions with areas > area_thrshld
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

GRAIN_NUM = 2;

    default_area_threshold = [];
    default_show_labels = true;
    
    p = inputParser;
    addRequired(p, 'seg_map');
    addOptional(p, 'area_thrshld', default_area_threshold);
    addParameter(p, 'ShowLabels', default_show_labels); 
    parse(p, seg_map, varargin{:});
    
    seg_map = p.Results.seg_map;
    area_thrshld = p.Results.area_thrshld;
    show_labels = p.Results.ShowLabels;

    % remove webbing by setting = 0
    seg_map(seg_map ~= GRAIN_NUM) = 0;
    
    BW_iq = bwlabel(seg_map,4); % segment grains

    rp = regionprops(BW_iq, 'Area'); % get grain areas
    areas = cat(1,rp.Area);
    
    lbls = unique(BW_iq); lbls(lbls == 0) = [];
    
    if isempty(area_thrshld)
        area_thrshld = -0.01;
    end
    
    lbls_sort_by_area = sortrows([lbls(:), areas], 2, 'descend');
    lbls_sort_by_area(lbls_sort_by_area(:,2) < area_thrshld,:) = []; % labels wish to keep in segmentation    
    
    lbls_with_small_areas = setdiff(lbls, lbls_sort_by_area);
    BW_iq(ismember(BW_iq, lbls_with_small_areas)) = 0;
    
    if show_labels
        fig = function_bwshowlabels(BW_iq, 'centroid');
    else
        figure; fig = imshow(label2rgb(BW_iq));
    end
    lbls2include = lbls_sort_by_area(:,1); % labels to use if wanting to sort by area
end