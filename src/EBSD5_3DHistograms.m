%% Description
% Figure 6 3D histograms.

close all; clear; clc;
addpath('Visualization')
addpath('3DHistogram')
addpath('OldGrainProps')
addpath('GrainProps Outputs')

savefigs = true;

%% Loading - Originally Used Data in Paper...
load('e03_cln3_no_ci_grains_only_ebsd_seg_18-Jul-2019 085726.mat'); gp_grains = grain_props;
load('e03_webbings_ebsd_seg_17-Jul-2019 101226.mat'); gp_boundaries = grain_props; 
load('e03_cln3_entire_ptc_ebsd_seg_17-Jul-2019 113107.mat'); gp_all = grain_props; 
load('e03_cln0_ci0_noise_ebsd_seg_22-Jul-2019 164217.mat'); gp_bckgrd = grain_props;
close all;

%% Orientations by pixel - Original Uncleaned Data
% directional histogram, pixel-by-pixel
fig11 = create_3D_hists(gp_all, gp_all.BW); view([140,0]); fig_stds()
fig12 = create_3D_hists(gp_grains, gp_grains.BW); view([140,0]); fig_stds()
fig13 = create_3D_hists(gp_boundaries, gp_boundaries.BW); view([140,0]); fig_stds()
fig14 = create_3D_hists(gp_bckgrd, gp_bckgrd.BW); view([140,0]); fig_stds()

fig21 = create_3D_hists(gp_all, gp_all.BW); view([-40,0]); fig_stds()
fig22 = create_3D_hists(gp_grains, gp_grains.BW); view([-40,0]); fig_stds()
fig23 = create_3D_hists(gp_boundaries, gp_boundaries.BW); view([-40,0]); fig_stds()
fig24 = create_3D_hists(gp_bckgrd, gp_bckgrd.BW); view([-40,0]); fig_stds()

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
load('2020-05-20-16-45-47_e03_cln3_entire_ptc_ebsd_seg.mat'); new_all  = grain_props;
load('2020-05-20-16-08-33_e03_cln3_ci0_grains_only_ebsd_seg.mat'); new_grains = grain_props;
close all;

%% Orientations by pixel - New Data
f41 = create_3D_hists(new_all, new_all.BW); view([140,0]); fig_stds()
f42 = create_3D_hists(new_all, new_grains.BW); view([140,0]); fig_stds()
f43 = create_3D_hists(new_all, (~new_grains.BW & new_all.BW)); view([140,0]); fig_stds()
f44 = create_3D_hists(new_all, gp_bckgrd.BW); view([140,0]); fig_stds()

f51 = create_3D_hists(new_all, new_all.BW); view([-40,0]); fig_stds()
f52 = create_3D_hists(new_all, new_grains.BW); view([-40,0]); fig_stds()
f53 = create_3D_hists(new_all, (~new_grains.BW & new_all.BW)); view([-40,0]); fig_stds()
f54 = create_3D_hists(new_all, gp_bckgrd.BW); view([-40,0]); fig_stds()

%% New backgrounds
ptc_only = function_mat2col(new_all.xyz_cleaned);
f61 = figure; f61.Color = 'white';
imshow(function_hide_background(ptc_only, new_all.BW, true))
f61.Units = 'inches'; f61.Position = [0.1,1,2.5,2.75];

f62 = figure; f62.Color = 'white';
imshow(function_hide_background(ptc_only, new_grains.BW, true))
f62.Units = 'inches'; f62.Position = [2.7,1,2.5,2.75];

f63 = figure; f63.Color = 'white';
imshow(function_hide_background(ptc_only, (~new_grains.BW & gp_all.BW), true))
f63.Units = 'inches'; f63.Position = [5.3,1,2.5,2.75];

f64 = figure; f64.Color = 'white';
imshow(function_hide_background(ptc_only, gp_bckgrd.BW, true))
f64.Units = 'inches'; f64.Position = [7.8,1,2.5,2.75];


%% Saving
save_fmt = 'svg';
if savefigs
    % front view
    saveas(f41, 'Figures/6_3dhist_all_front', save_fmt)
    saveas(f42, 'Figures/6_3dhist_grains_front', save_fmt)
    saveas(f43, 'Figures/6_3dhist_boundaries_front', save_fmt)
    saveas(f44, 'Figures/6_3dhist_background_front', save_fmt)
    
    % rear view
    saveas(f51, 'Figures/6_3dhist_all_rear', save_fmt)
    saveas(f52, 'Figures/6_3dhist_grains_rear', save_fmt)
    saveas(f53, 'Figures/6_3dhist_boundaries_rear', save_fmt)
    saveas(f54, 'Figures/6_3dhist_background_rear', save_fmt)
    
    saveas(f61, 'Figures/6_mask_all', save_fmt)
    saveas(f62, 'Figures/6_mask_grains', save_fmt)
    saveas(f63, 'Figures/6_mask_boundary', save_fmt)
    saveas(f64, 'Figures/6_mask_background', save_fmt)
end

%% Plot Help Functions
function fig_stds()
    f = gcf; f.Color = 'white'; f.Units = 'inches'; 
    ax = gca; ax.Visible = 'off'; 
end
