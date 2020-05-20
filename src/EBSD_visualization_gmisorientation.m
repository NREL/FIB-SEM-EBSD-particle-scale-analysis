%% About
% This script is to create Figure 8 in The application of electron 
% backscatter diffraction for investigating intra-particle grain
% architectures and boundaries in lithium ion electrodes

%% Setup
close all; clear; clc;
addpath('Visualization')

%% Loading
% grains only
load('2020-05-20-16-08-33_e03_cln3_ci0_grains_only_ebsd_seg.mat'); close all;
gp_grains = grain_props;

% % FULL particle. cleaning applied
load('2020-05-20-16-45-47_e03_cln3_entire_ptc_ebsd_seg.mat'); close all;
gp_ptc = grain_props;

% % for boundary region
% % NOTE, THIS HISTOGRAM SHOULD BE OBTAINED FROM FULL GRAIN OVERLAID WITH
% % SEGMENTATION PATTERN. MADE THE FOLLOWING ANYWAYS
% load('2020-05-20-18-00-54_e03_boundaries_ebsd_seg.mat');
% gp_boundary = grain_props;

% % most frequency orientation adopted - already created and works
% load('2020-01-12-15-03-16_EBSD_03_mfv.mat');

ebsd_img = imread('DF-NMC-CF-01-e_03.tif');

%% Color maps for impact of cleaning
figure; imshow(function_view_speckle_removed(gp_grains)); 
figure; imshow(function_view_speckle_removed(gp_ptc)); 

%% Red-white intragrain misorientations
figure; imshow(function_view_intragrain_misorientation(gp_grains)); 

%% Visualizations: Intra-grain angles per boundary pixel
figure; histogram(gp_grains.intragrain_border_angles(:,5), 72)
figure; histogram(gp_ptc.intragrain_border_angles(:,5), 72)

figure; function_show_border_angles(gp_grains, gp_grains.intragrain_border_angles);
figure; function_show_border_angles(gp_ptc, gp_ptc.intragrain_border_angles);

% if ~isempty(grain_props.intragrain_border_angles)
%     f1 = figure; histogram(grain_props.intragrain_border_angles(:,5), 72); 
%     xlabel('g-misorientation (degrees)'); ylabel('Frequency')
%     f1.Color = 'white'; f1.Units = 'inches'; f1.Position = [1,1,2.75,2.25];
%     figure_intragrain_border_angles = function_show_border_angles(grain_props, grain_props.intragrain_border_angles);
% end

%% Visualizations: Grain-grain angles per boundary pixel 
if ~isempty(grain_props.grain_border_angles)
    f2 = figure; histogram(real(grain_props.grain_border_angles(:,5)), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    f2.Color = 'white'; f2.Units = 'inches'; f2.Position(3) = 2.75; f2.Position(4) = 2.25;
    figure_grain_grain_border_angles = function_show_border_angles(grain_props, grain_props.grain_border_angles);
end

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
