%% Description
% Use of some functions for visualization.

close all; clear; clc;
addpath('Visualization')
addpath('GrainProps Outputs')
addpath('Inputs')

%% Loading
load('gp_ptc_w_grains_cleaned_individually.mat');
ebsd_img = imread('DF-NMC-CF-01-e_03.tif');

%% Grain Border Map
fig_gbmp = figure; fig_gbmp.Units = 'inches';
imshow(grain_props.ptc_map); hold on;
for n = 1:length(grain_props.grain_boundaries)
    plot(grain_props.grain_boundaries{n}{1}(:,2), grain_props.grain_boundaries{n}{1}(:,1), 'Color', [0.5, 0.5, 0.5])
end
fig_gbmp.Position(3) = 2.75; fig_gbmp.Position(4) = 2.25;

%% Intragrain Boundaries
figure; imshow(label2rgb(grain_props.BW)); hold on; 
for n = 1:length(grain_props.intragrain_boundaries)
    if iscell(grain_props.intragrain_boundaries{n})
        plot(grain_props.intragrain_boundaries{n}{1}(:,2), grain_props.intragrain_boundaries{n}{1}(:,1), 'k')
    end
end

%% Montage
euler_img = mat2col(grain_props.euler);
xyz_pos_img = mat2col(grain_props.xyz_pos); 
xyz_pos_img_ci = apply_CI(xyz_pos_img, grain_props.CI, 0); % normalize xyz values to positive 0-1
xyz_cleaned_img = mat2col(grain_props.xyz_cleaned);
xyz_cleaned_img_ci = apply_CI(xyz_cleaned_img, grain_props.CI, 0);
image_quality_img = mat2col(grain_props.iq);

montage_figure = figure; montage({ebsd_img, image_quality_img, label2rgb(grain_props.BW), grain_props.ptc_map, euler_img, xyz_pos_img, ...
    xyz_cleaned_img, xyz_cleaned_img_ci})

%% Segmentation Map Remove Unsegmented Regions
img = hide_background(grain_props.xyz_cleaned, grain_props.BW, true);
figure; imshow(img)

%% Figure Modifications
fighandles = findobj('Type', 'figure');
for n = 1:length(fighandles)
    fighandles(n).Color = 'white';
    fighandles(n).Units = 'inches';
    fighandles(n).Position = [1,1,2.5,2.75];
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
end
