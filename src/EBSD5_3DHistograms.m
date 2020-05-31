%% Description
% Figure 6 3D histograms.

close all; clear; clc;
addpath('Visualization')
addpath('3DHistogram')
addpath('OldGrainProps')
addpath('GrainProps Outputs')

%% Loading - Originally Used Data in Paper...
load('')

load('e03_cln3_no_ci_grains_only_ebsd_seg_18-Jul-2019 085726.mat'); gp_grains = grain_props;
load('e03_webbings_ebsd_seg_17-Jul-2019 101226.mat'); gp_boundaries = grain_props; 
load('e03_cln3_entire_ptc_ebsd_seg_17-Jul-2019 113107.mat'); gp_all = grain_props; 
load('e03_cln0_ci0_noise_ebsd_seg_22-Jul-2019 164217.mat'); gp_bckgrd = grain_props;
close all;

%% Orientations by pixel - Original Uncleaned Data
% directional histogram, pixel-by-pixel
fig11 = create_3D_hists(gp_all); view([140,0]); fig_stds()
fig12 = create_3D_hists(gp_grains); view([140,0]); fig_stds()
fig13 = create_3D_hists(gp_boundaries); view([140,0]); fig_stds()
fig14 = create_3D_hists(gp_bckgrd); view([140,0]); fig_stds()

fig21 = create_3D_hists(gp_all); view([-40,0]); fig_stds()
fig22 = create_3D_hists(gp_grains); view([-40,0]); fig_stds()
fig23 = create_3D_hists(gp_boundaries); view([-40,0]); fig_stds()
fig24 = create_3D_hists(gp_bckgrd); view([-40,0]); fig_stds()

%% Backgrounds
ptc_only = function_mat2col(gp_all.xyz_cleaned);
f31 = figure; 
imshow(function_hide_background(ptc_only, gp_all.BW, true))
f31.Units = 'inches'; f31.Position = [0.1,1,2.5,2.75];

f32 = figure; imshow(function_hide_background(ptc_only, (gp_grains.BW & gp_all.BW), true))
f32.Units = 'inches'; f32.Position = [2.7,1,2.5,2.75];

f33 = figure; imshow(function_hide_background(ptc_only, (gp_boundaries.BW & gp_all.BW), true))
f33.Units = 'inches'; f33.Position = [5.3,1,2.5,2.75];

f34 = figure; imshow(function_hide_background(ptc_only, gp_bckgrd.BW, true))
f34.Units = 'inches'; f34.Position = [7.8,1,2.5,2.75];

%% Loading - New Set of Data


%% Plot Help Functions

function fig_stds()
    f = gcf; f.Color = 'white'; f.Units = 'inches'; 
%     f.Position = [1, 3, 2.5, 2.75];
    ax = gca; ax.Visible = 'off'; 
end
