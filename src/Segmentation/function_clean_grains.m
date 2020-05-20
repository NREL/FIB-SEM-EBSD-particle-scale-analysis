function grains = function_clean_grains(seg_map, keep_grains)
%function_clean_grains repalces grains not in keep_grains w/ NaN
%   grains = function_clean_grains(seg_map, keep_grains)
%       removes grains from matrix segemeneted from seg_map labeled in
%       keep_grains
%   Inputs
%       seg_map - original segmentation map
%       keep_grains - list of grain labels shown with function_get_grains
%           which are kept for the dilation procedure which removes the
%           boudnaries
% 
%   Outputs
%       grains - NaN-containing matrix which has removed grains. Intended
%           for use in function_combine_grains_webs
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL    
    
GRAIN_NUM = 2;

    % remove webbing by setting = 0
    seg_map(seg_map ~= GRAIN_NUM) = 0;
    
    BW_iq = bwlabel(seg_map,4); % segment grains

    rp = regionprops(BW_iq, 'Area'); % get grain areas
    areas = cat(1,rp.Area);
    
    lbls = unique(BW_iq); lbls(lbls == 0) = [];
        
    lbls_to_go = setdiff(lbls, keep_grains);
    BW_iq(ismember(BW_iq, lbls_to_go)) = NaN;
     
    BW_iq(isnan(BW_iq)) = 0;
    
    grains = BW_iq;
end