%% Description
% Figure 5 plots.

%% Setup
close all; clear; clc;
addpath('Visualization')
addpath('GrainProps Outputs')
addpath('Inputs')

%% File Loading
load('2020-05-22-18-39-12_test.mat'); close all;
ebsd_img = imread('DF-NMC-CF-01-e_03.tif');

%% Edge Map
fig_edgemap = figure; im = image(grain_props.ptc_edge_map.*grain_props.um_per_pix);
fig_edgemap.Units = 'inches'; fig_edgemap.Position(3) = 3.0417; fig_edgemap.Position(4) = 2.25;
im.CDataMapping = 'scaled'; colorbar; colormap(jet)

%% Morphology 4 bins
if length(grain_props.grain_areas) > 1
    [eccentricity_freq, dn1] = binned_dmap(grain_props, 4, 'eccentricity', label2rgb(grain_props.BW));
    [area_freq, dn2] = binned_dmap(grain_props, 4, 'area', label2rgb(grain_props.BW));
    close(dn1); close(dn2);
    [poa_freq, figure_binned_dmap, dat] = binned_dmap(grain_props, 4, 'poa', mat2gray(grain_props.ptc_map)); %
end

% Background to show bins 
figure(figure_binned_dmap); hold on;
for n = 1:length(grain_props.grain_boundaries)
    plot(grain_props.grain_boundaries{n}{1}(:,2), grain_props.grain_boundaries{n}{1}(:,1), 'Color', [0.6, 0.6, 0.6])
end

eccentricity_freq.Position = [1 4 2.2604 2.3958];
area_freq.Position = [3.3 4 2.2604 2.3958];
poa_freq.Position = [5.6 4 2.2604 2.3958];
figure_binned_dmap.Position = [7.9 4 2.2604 2.3958];

%% Morphology 1 bin
if length(grain_props.grain_areas) > 1
    [eccentricity_freq, dn1] = binned_dmap(grain_props, 1, 'eccentricity', label2rgb(grain_props.BW));
    [area_freq, dn2] = binned_dmap(grain_props, 1, 'area', label2rgb(grain_props.BW));
    close(dn1); close(dn2);
    [poa_freq, figure_binned_dmap, dat] = binned_dmap(grain_props, 1, 'poa', mat2gray(grain_props.ptc_map)); %
end

% Background to show bins 
figure(figure_binned_dmap)
hold on;
for n = 1:length(grain_props.grain_boundaries)
    plot(grain_props.grain_boundaries{n}{1}(:,2), grain_props.grain_boundaries{n}{1}(:,1), 'Color', [0.6, 0.6, 0.6])
end

eccentricity_freq.Position = [1 0.5 2.2604 2.3958];
area_freq.Position = [3.3 0.5 2.2604 2.3958];
poa_freq.Position = [5.6 0.5 2.2604 2.3958];
figure_binned_dmap.Position = [7.9 0.5 2.2604 2.3958];

%% Figure Modifications
fighandles = findobj('Type', 'figure');
for n = 1:length(fighandles)
    fighandles(n).Color = 'white';
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
end
