function [BW_rdy_seg, fig_BW_rdy_seg] = function_bckgrnd_to_web(BW_combined, bck_lbls)
%function_bckgrnd_to_web returns segmented matrix ready for dilation of grains 
%   BW_rdy_seg = function_bckgrnd_to_web(BW_combined, num, bck_lbls) uses
%       bck_lbls to replace anything but actual background with value = 1,
%       which corresponds to webbing
%   
%   Inputs
%       BW_iq_comb - matrix where 0 == background, 1 == webbing and any # >
%           1 is a grain 
%       num - specifies that 0 is background
%       bck_lbls - specifies which backgorudn labelsa are to be kept as
%           background, as visualized in function_show_backgrounds
% 
%   Outputs
%       BW_rdy_seg - segmented matrix ready for use in
%           function_passBW_remove_segmentation_boundaries 
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

BCK_LBL = 0; % background of matrix

    BW_iq_og = BW_combined; 
    BW_combined(~ismember(BW_combined, BCK_LBL)) = NaN; % non-background change to NaN
    BW_combined(ismember(BW_combined, BCK_LBL)) = 1; % background to 1
    BW_combined(isnan(BW_combined)) = 0; % NaN to background
    
    % need better algorithm to extract background
    BW_iq_white_dot_rid_labeled = bwlabel(BW_combined); % label all background 'particles'
    lbls = unique(BW_iq_white_dot_rid_labeled); lbls(lbls == 0) = [];
    lbls_to_make1 = setdiff(lbls,bck_lbls);
    
    BW_iq_og(ismember(BW_iq_white_dot_rid_labeled, lbls_to_make1)) = 1;
    
    BW_rdy_seg = BW_iq_og;    
    fig_BW_rdy_seg = figure; imshow(label2rgb(BW_rdy_seg));
end