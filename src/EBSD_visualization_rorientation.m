%% About
% This script is to create Figure 7 in The application of electron 
% backscatter diffraction for investigating intra-particle grain
% architectures and boundaries in lithium ion electrodes

%% Setup
close all; clear; clc;
addpath('Visualization')

%% Loading/Inputs
load('2020-01-12-14-20-15_EBSD_03_run1'); close all;
ebsd_img = imread('DF-NMC-CF-01-e_03.tif');
ptc_r105090 = [7.1, 9.3, 12.1]./2; % in microns, spread of particle radii

%% Angle of Orientations Relative to Radial Direction - varied particle diameter
for n = 1:length(ptc_r105090)
    roffset = function_roffset(grain_props, ptc_r105090(n));
    angles_to_r_above{n} = function_hist_rs(grain_props, roffset);
    angles_to_r_below{n} = function_hist_rs(grain_props, -roffset);
    r_mis_pixel_map_pos{n} = function_map_rmisorientation(grain_props, roffset);
    r_mis_pixel_map_neg{n} = function_map_rmisorientation(grain_props, -roffset);
end

% assuming slice is above the particle center
f1 = figure; f1.Color = 'white'; f1.Units = 'inches'; f1.Position = [1,2.4,2,2.75];
h = histogram(angles_to_r_above{2}, 18); hold on;
[n1, edges] = histcounts(angles_to_r_above{1}, 18);
[n3, ~] = histcounts(angles_to_r_above{3}, 18);
err = errorbar(0.5*(edges(1:end-1) + edges(2:end)), ...
    h.Values, h.Values-min([n1;n3]), max([n1;n3])-h.Values); 
err.LineStyle = 'none'; err.Color = [0 0 0];
ylabel('# grains with orientation'); xlabel('Radial misalignment (degrees)')
ylim([0 30]);

% assuming slice is below the particle center
f2 = figure; f2.Color = 'white'; f2.Units = 'inches'; f2.Position = [3.1,2.4,2,2.75];
h = histogram(angles_to_r_below{2}, 18); hold on;
[n1, edges] = histcounts(angles_to_r_below{1}, 18);
[n3, ~] = histcounts(angles_to_r_below{3}, 18);
err = errorbar(0.5*(edges(1:end-1) + edges(2:end)), ...
    h.Values, h.Values-min([n1;n3]), max([n1;n3])-h.Values); 
err.LineStyle = 'none'; err.Color = [0 0 0];
ylabel('# grains with orientation'); xlabel('Radial misalignment (degrees)')
ylim([0 30]);

%% Colormaps of g-orientation
f3 = figure; imshow(mat2gray(90 - r_mis_pixel_map_pos{3})); 
f3.Units = 'inches'; f3.Position = [5.6 2.4 4.2 4.1];

f4 = figure; imshow(mat2gray(90 - r_mis_pixel_map_neg{3})); 
f4.Units = 'inches'; f4.Position = [9.9 2.4 4.2 4.1];

%% Figure Modifications
fighandles = findobj('Type', 'figure');
for n = 1:length(fighandles)
    fighandles(n).Color = 'white';
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 8;
end
