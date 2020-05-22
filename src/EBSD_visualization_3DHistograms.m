%% analysis using grain_props
close all; clear; clc;
addpath('Visualization')
addpath('3DHistogram')

%% Loading - Originally Used Data in Paper...
load('e03_cln3_no_ci_grains_only_ebsd_seg_18-Jul-2019 085726.mat'); gp_grains = grain_props;
load('e03_webbings_ebsd_seg_17-Jul-2019 101226.mat'); gp_boundaries = grain_props; 
load('e03_cln3_entire_ptc_ebsd_seg_17-Jul-2019 113107.mat'); gp_all = grain_props; 
load('e03_cln0_ci0_noise_ebsd_seg_22-Jul-2019 164217.mat'); gp_bckgrd = grain_props;
close all;

%% Orientations by pixel - Original Uncleaned Data
% directional histogram, pixel-by-pixel
fig11 = create_3D_hists(gp_all); view([140,0])
fig12 = create_3D_hists(gp_grains); view([140,0])
fig13 = create_3D_hists(gp_boundaries); view([140,0])
fig14 = create_3D_hists(gp_bckgrd); view([140,0])

fig21 = create_3D_hists(gp_all); view([-40,0])
fig22 = create_3D_hists(gp_grains); view([-40,0])
fig23 = create_3D_hists(gp_boundaries); view([-40,0])
fig24 = create_3D_hists(gp_bckgrd); view([-40,0])

%%

%% Loading - New Set of Data

%% Figure Modifications
fighandles = findobj('Type', 'figure');
for n = 1:length(fighandles)
    fighandles(n).Color = 'white';
%     fighandles(n).Position = [120 120 250 285];
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
end
