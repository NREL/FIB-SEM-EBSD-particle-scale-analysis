%% About
% This script is to create Figure 8 in The application of electron 
% backscatter diffraction for investigating intra-particle grain
% architectures and boundaries in lithium ion electrodes

%% Setup
close all; clear; clc;
addpath('Visualization')

%% Loading
% % grains only
% load('2020-05-20-16-08-33_e03_cln3_ci0_grains_only_ebsd_seg.mat'); close all;

% % FULL grain. cleaning applied
% load('2020-05-20-16-45-47_e03_cln3_entire_ptc_ebsd_seg.mat'); close all;

% for boundary region
% NOTE, THIS HISTOGRAM SHOULD BE OBTAINED FROM FULL GRAIN OVERLAID WITH
% SEGMENTATION PATTERN. MADE THE FOLLOWING ANYWAYS
load('2020-05-20-18-00-54_e03_boundaries_ebsd_seg.mat');



% for slices, and first 2 of figure 7
%   'e03_updtRandXYZ_cln3_ci05_ebsd_seg_11-Aug-2019 213139.mat'

% most frequency orientation adopted
%   '2020-01-12-15-03-16_EBSD_03_mfv.mat'

ebsd_img = imread('DF-NMC-CF-01-e_03.tif');

%% Visualizations: Color maps for cleaning impact of cleaning
img_filtered_noise = function_view_speckle_removed(grain_props); % image cleaning - compares xyz_pos and xyz_cleaned
intragrain_misorientation = function_view_intragrain_misorientation(grain_props); % after cleaning - shows within each grain the levels of misorientation

figure; imshow(img_filtered_noise)
figure; imshow(intragrain_misorientation)

%% Visualizations: Intra-grain angles per boundary pixel
if ~isempty(grain_props.intragrain_border_angles)
    figure_ig_bdr_angl_histo = figure; histogram(grain_props.intragrain_border_angles(:,5), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    figure_ig_bdr_angl_histo.Color = 'white'; figure_ig_bdr_angl_histo.Units = 'inches'; figure_ig_bdr_angl_histo.Position(3) = 2.75; figure_ig_bdr_angl_histo.Position(4) = 2.25;
    figure_intragrain_border_angles = function_show_border_angles(grain_props, grain_props.intragrain_border_angles);
end

%% Visualizations: Grain-grain angles per boundary pixel 
if ~isempty(grain_props.grain_border_angles)
    figure_grain_grain_border_angles_histo = figure; histogram(real(grain_props.grain_border_angles(:,5)), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    figure_grain_grain_border_angles_histo.Color = 'white'; figure_grain_grain_border_angles_histo.Units = 'inches'; figure_grain_grain_border_angles_histo.Position(3) = 2.75; figure_grain_grain_border_angles_histo.Position(4) = 2.25;
    figure_grain_grain_border_angles = function_show_border_angles(grain_props, grain_props.grain_border_angles);
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

%% Intragrain fractions
count = 0;
grn_size = [];
grn_frac = [];
grn_frac_tot = [];
grn_size_tot = [];

for n = 1:length(grain_props.grain_labels) % per each grain
    new_mat = grain_props.BW_intragrain;
    new_mat(grain_props.BW ~= grain_props.grain_labels(n)) = 0;
    rem = unique(new_mat); rem(rem == 0) = []; % rem is remaining 
    grn_size_n = length(find(new_mat > 0));
    curr_grn_size = [];
    curr_grn_frac = [];
    count = 0;
    for m = 1:length(rem)
        count = count + 1;
        curr_grn_size(count) = grn_size_n*(grain_props.um_per_pix^2);
        [r,c] = find(grain_props.BW_intragrain == rem(m)); % grain size
        curr_grn_frac(count) = length(r)*(grain_props.um_per_pix^2)/curr_grn_size(count);
        if curr_grn_frac(count) > 1; error('bigger than grain?'); end
    end
    srs = sortrows([curr_grn_size(:), curr_grn_frac(:)], 2, 'descend');
    srs(1,:) = []; % remove largest component of grain
    curr_grn_size = srs(:,1);
    curr_grn_frac = srs(:,2);
    
    grn_size = cat(1, grn_size, curr_grn_size(:));
    grn_frac = cat(1, grn_frac, curr_grn_frac(:));
    
    
    grn_frac_tot(n) = sum(curr_grn_frac); % total amount of grain that is not most frequent size
    grn_size_tot(n) = grn_size_n*(grain_props.um_per_pix^2);
end
% individual intra-grains
fig_intg_frac = figure; scatter(grn_size, grn_frac, 3, 'filled');
fig_intg_frac.Color = 'white'; fig_intg_frac.Units = 'inches'; fig_intg_frac.Position(3:4) = [2.75, 2.25];
xlabel('Grain size (\mum)'); ylabel('f_{individual}')
a_intg_fran = gca; a_intg_fran.FontSize = 10;

% total fraction of intragrains
fig_intg_tfrac = figure; scatter(grn_size_tot, grn_frac_tot, 8, 'filled');
fig_intg_tfrac.Color = 'white'; fig_intg_tfrac.Units = 'inches'; fig_intg_tfrac.Position(3:4) = [2.75, 2.25];
xlabel('Grain size (\mum)'); ylabel('f_{total}')
fig_intg_tfrac = gca; fig_intg_tfrac.FontSize = 10;

%% Segmentation Map Remove Unsegmented Regions
img = function_hide_background(grain_props.xyz_cleaned, grain_props.BW);
figure; imshow(img)

%% Figure Modifications
fighandles = findobj('Type', 'figure');
for n = 1:length(fighandles)
    fighandles(n).Color = 'white';
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
end
