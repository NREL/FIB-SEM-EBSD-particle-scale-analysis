%% About
% This script is to create Figure 7 in The application of electron 
% backscatter diffraction for investigating intra-particle grain
% architectures and boundaries in lithium ion electrodes

%% Setup
close all; clear; clc;
addpath('Visualization')
addpath('OldGrainProps')

%% Loading/Inputs
load('2020-05-22-18-39-12_test.mat'); close all;
% load('e03_updtRandXYZ_cln3_ci05_ebsd_seg_11-Aug-2019 213139.mat'); close all;
% grain_props.um_per_pix = grain_props.pix2um; grain_props.um_per_pix = 1/(137-17);
% grain_props.orientation_frequencies = grain_props.grain_zorientation_frequencies;

ptc_r105090 = [7.1, 9.3, 12.1]./2; % in microns, spread of particle radii

%% Angle of Orientations Relative to Radial Direction - varied particle diameter
for n = 1:length(ptc_r105090)
    roffset = function_roffset(grain_props, ptc_r105090(n));
    angles_to_r_above{n} = function_hist_rs(grain_props, roffset);
    angles_to_r_below{n} = function_hist_rs(grain_props, -roffset);
    r_mis_pixel_map_pos{n} = function_map_rmisorientation(grain_props, roffset);
    r_mis_pixel_map_neg{n} = function_map_rmisorientation(grain_props, -roffset);
end

%% Per Grain
% assuming slice is above the particle center
f1 = figure; 
hist_clean(angles_to_r_above)

% assuming slice is below the particle center
f2 = figure; 
hist_clean(angles_to_r_below)

%% Per pixel
angles_above = process_angle_map(grain_props, r_mis_pixel_map_pos);
figure;
hist_clean(angles_above)
ylim('auto')

angles_below = process_angle_map(grain_props, r_mis_pixel_map_neg);
figure;
hist_clean(angles_below)
ylim('auto')

%% Colormaps of g-orientation
f3 = figure; imshow(mat2gray(90 - r_mis_pixel_map_pos{2})); 
f3.Units = 'inches'; f3.Position = [5.6 2.4 4.2 4.1];

f4 = figure; imshow(mat2gray(90 - r_mis_pixel_map_neg{2})); 
f4.Units = 'inches'; f4.Position = [9.9 2.4 4.2 4.1];

%% Plot Function
function hist_clean(M)
    f = gcf; 
    f.Color = 'white'; 
    f.Units = 'inches'; 
    f.Position = [1,2.4,2,2.75];
    
    h = histogram(M{2}, 18); hold on; 
    h.EdgeColor = [.4 .4 .4]; 
    h.EdgeAlpha = .5;
    
    ax = gca; ax.FontSize = 8;
    [n1, edges] = histcounts(M{1}, h.BinEdges);
    [n3, ~] = histcounts(M{3}, h.BinEdges);
   
    err = errorbar(0.5*(edges(1:end-1) + edges(2:end)), ...
        h.Values, h.Values-min([n1;n3;h.Values]), max([n1;n3;h.Values])-h.Values); 
    err.LineStyle = 'none'; err.Color = .3*ones(1,3);
    err.CapSize = 3;
    
    ylabel('# grains with orientation'); 
    xlabel('r-orientation (degrees)');
    ylim([0 30]);
end

function M = process_angle_map(grain_props, A)
    for n = 1:length(A)
        rm_bckgrd = A{n}; rm_bckgrd(~grain_props.BW) = nan;
        lin_angles2 = reshape(rm_bckgrd, numel(rm_bckgrd), 1); 
        lin_angles2(isnan(lin_angles2)) = [];
        M{n} = lin_angles2;
    end
end
