%% analysis using grain_props
close all; clear; clc;
addpath('Visualization')

%%
% load grain_props
% load('2020-01-12-14-20-15_EBSD_03_run1');
load('2020-05-19-18-42-45_EBSD_03_run1'); close all;

% for slices, and first 2 of figure 7
%   'e03_updtRandXYZ_cln3_ci05_ebsd_seg_11-Aug-2019 213139.mat'
% for grains only
load('e03_cln3_ci05_grains_only_ebsd_seg_18-Jul-2019 104019.mat'); gp_grains = grain_props;
% for boundary region
load('e03_webbings_ebsd_seg_17-Jul-2019 101226.mat'); gp_boundaries = grain_props;
% FULL grain. cleaning applied
load('e03_cln3_entire_ptc_ebsd_seg_17-Jul-2019 113107.mat'); gp_all = grain_props;
% most frequency orientation adopted
%   '2020-01-12-15-03-16_EBSD_03_mfv.mat'
close all;

%% Orientations by pixel
% directional histogram, pixel-by-pixel
fig3 = create_3D_hists(gp_all);
fig1 = create_3D_hists(gp_grains);
fig2 = create_3D_hists(gp_boundaries);



%% Figure Modifications
fighandles = findobj('Type', 'figure');
for n = 1:length(fighandles)
    fighandles(n).Color = 'white';
%     fighandles(n).Position = [120 120 250 285];
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
end
