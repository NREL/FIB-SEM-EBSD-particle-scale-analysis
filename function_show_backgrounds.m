function [fig, fig_og_bckgrd, lbls2include] = function_show_backgrounds(BW_iq_comb, num_backgrounds)
%function_show_backgrounds labels each background component by number to
%   fig =  function_show_backgrounds(BW_iq_comb) segements background and
%       labels resulting regions
%   fig =  function_show_backgrounds(BW_iq_comb, num_backgrounds)
%       segments background but only the biggest num_backgrounds 
%   Inputs
%       BW_iq_comb - segmented matrix
%       num_backgrounds - number of regions to display (does not affect
%       	labeling)
% 
%   Outputs
%       fig - handle to fig which shows labeled backgrounds
%       fig_og_bckgrd - original background image
%       lbls2include - list of lbls denoted by num_backgrounds. Is list of
%           all lbls if ignored
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

BCK_LBL = 0; % background of matrix

% num is the background number (typically 0)
    BW_iq_og = BW_iq_comb; 
    BW_iq_comb(~ismember(BW_iq_comb, BCK_LBL)) = NaN; % non-background change to NaN
    BW_iq_comb(ismember(BW_iq_comb, BCK_LBL)) = 1; % background to 1
    BW_iq_comb(isnan(BW_iq_comb)) = 0; % Nan to background
    
    % need better algorithm to extract background
    BW_iq_white_dot_rid_labeled = bwlabel(BW_iq_comb); % label all background 'particles'
    bckgnd_lbls = unique(BW_iq_white_dot_rid_labeled); bckgnd_lbls(bckgnd_lbls  == 0) = [];
    
    fig_og_bckgrd = figure; imshow(label2rgb(BW_iq_white_dot_rid_labeled))
    
    rp = regionprops(BW_iq_white_dot_rid_labeled, 'Area');
    areas = cat(1,rp.Area); % sort areas to max
    
    if ~exist('num_backgrounds', 'var')
        num_backgrounds = length(bckgnd_lbls);
    end
    
    lbls_sort_by_area = sortrows([bckgnd_lbls(:), areas], 2, 'descend');
    lbls_sort_by_area = lbls_sort_by_area(1:num_backgrounds,:); % filter anything below
    lbls2include = lbls_sort_by_area(:,1);
    
    BW_iq_white_dot_rid_labeled(~ismember(BW_iq_white_dot_rid_labeled, lbls2include)) = 0;
    
    fig = function_bwshowlabels(BW_iq_white_dot_rid_labeled, 'first');
end