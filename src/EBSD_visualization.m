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
%   'e03_cln3_ci05_grains_only_ebsd_seg_18-Jul-2019 104019.mat'
% for boundary region
%   'e03_webbings_ebsd_seg_17-Jul-2019 101226.mat'
% FULL grain. cleaning applied
%   'e03_cln3_entire_ptc_ebsd_seg_17-Jul-2019 113107.mat'
% most frequency orientation adopted
%   '2020-01-12-15-03-16_EBSD_03_mfv.mat'

ebsd_img = imread('DF-NMC-CF-01-e_03.tif');

%implement in original code
ptc_r105090 = [7.1, 9.3, 12.1]./2; % in microns, 
second_ptc_r = 9.3/2; % microns, for radial adjustments

%% Grain Border Map
fig_gbmp = figure; fig_gbmp.Units = 'inches';
imshow(grain_props.ptc_map); hold on;
for n = 1:length(grain_props.grain_boundaries)
    plot(grain_props.grain_boundaries{n}{1}(:,2), grain_props.grain_boundaries{n}{1}(:,1), 'Color', [0.5, 0.5, 0.5])
end
fig_gbmp.Position(3) = 2.75; fig_gbmp.Position(4) = 2.25;

%% Visualizations: Show Intragrain Boundaries
figure; imshow(label2rgb(grain_props.BW)); hold on; 
for n = 1:length(grain_props.intragrain_boundaries)
    if iscell(grain_props.intragrain_boundaries{n})
        plot(grain_props.intragrain_boundaries{n}{1}(:,2), grain_props.intragrain_boundaries{n}{1}(:,1), 'k')
    end
end

%% Visualization: Montage
xyzz_img = (xyzz-min(xyzz,[],'all'))./max(xyzz-min(xyzz,[],'all'),[],'all'); xyzz_img = function_apply_CI(xyzz_img, CI_map, 0); % normalize xyz values to positive 0-1 
xyz_pos_img = function_mat2col(xyz_pos); 
xyz_pos_img_ci = function_apply_CI(xyz_pos_img, CI_map, 0); % normalize xyz values to positive 0-1
xyz_cleaned_img = function_mat2col(grain_props.xyz_cleaned);
xyz_cleaned_img_ci = function_apply_CI(xyz_cleaned_img, grain_props.CI, 0);
image_quality_img = function_mat2col(image_quality);

montage_figure = figure; montage({ebsd_img, image_quality_img, label2rgb(grain_props.BW), grain_props.ptc_map, function_mat2col(xyzz), xyz_pos_img, img_filtered_noise, intragrain_misorientation,...
    xyz_cleaned_img, xyz_cleaned_img_ci, border_composite})

%% Visualizations: Orientations by pixel - Warning: 30+ minutes calculation 
% directional histogram, pixel-by-pixel
xyz_pos_for_reshape = grain_props.xyz_cleaned;
for n = 1:size(xyz_pos_for_reshape,3)
    temp_mat = xyz_pos_for_reshape(:,:,n);
    temp_mat(grain_props.BW == 0) = NaN; % ignore noise regions
    xyz_pos_for_reshape(:,:,n) = temp_mat;
end
A = permute(xyz_pos_for_reshape, [3,1,2]); % want to acquire data along column, 3 is of interest (x,y,z values)
B = reshape(A,3,size(A,2)*size(A,3)); % reshape into 3xlength
C = B'; %this can be used in directional histogram
C(isnan(C(:,1)), :) = [];

size(C)

tic % long long computation time (every single pixel being considered)
[fig, d] = function_hist3D_xyz(C,...
    'Representation', 'icosahedron',...
    'Subdivision', 1,...
    'ColorFaces', true, ...
    'PlotMethod', 'extrusion', ... % default, (above is 
    'BaseLine', 0.4); % baseline modifies origin location (0 = origin)
    a = gca;
    a.Children(5).Clipping = 'off';
    a.Children(6).Clipping = 'off';
    a.Children(3).Clipping = 'off';
    a.Children(4).Clipping = 'off';
    a.Children(2).Clipping = 'off';

% [figure_3dhist_per_pixel,~,~,frames_3dhist_per_pixel] = function_hist3D_xyz(C, 'ProduceVideo', true, 'ColorFaces', true);
% v=VideoWriter([append_save_name, 'orientations_per_pixel.avi']); open(v); for n=1:length(frames_3dhist_per_pixel); writeVideo(v, frames_3dhist_per_pixel{n}); end; close(v);
toc

%% Segmentation Map Remove Unsegmented Regions
img = function_hide_background(grain_props.xyz_cleaned, grain_props.BW);
figure; imshow(img)

%% Figure Modifications
fighandles = findobj('Type', 'figure');
for n = 1:length(fighandles)
    fighandles(n).Color = 'white';
%     fighandles(n).Position = [120 120 250 285];
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
end
