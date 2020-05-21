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

% FULL particle. cleaning applied
load('2020-05-20-16-45-47_e03_cln3_entire_ptc_ebsd_seg.mat'); close all;
gp_ptc = grain_props;

% most frequency orientation adopted - already created and works
load('2020-01-12-15-03-16_EBSD_03_mfv.mat');
gp_mfv = grain_props; close all;

% % for boundary region
% % NOTE, THIS HISTOGRAM SHOULD BE OBTAINED FROM FULL GRAIN OVERLAID WITH
% % SEGMENTATION PATTERN. MADE THE FOLLOWING ANYWAYS. NOT USED
% load('2020-05-20-18-00-54_e03_boundaries_ebsd_seg.mat');
% gp_boundary = grain_props;

ebsd_img = imread('DF-NMC-CF-01-e_03.tif');

%% Color maps for impact of cleaning
f1 = figure; imshow(function_view_speckle_removed(gp_grains)); 
f2 = figure; imshow(function_view_speckle_removed(gp_ptc)); 

%% Red-white intragrain misorientations
f3 = figure; imshow(function_view_intragrain_misorientation(gp_grains)); 

%% Visualizations: Intra-grain angles per boundary pixel
f4 = figure; 
plot_igba(gp_grains)
f4.Position(2) = 4;

f5 = figure; 
plot_igba(gp_ptc);
f5.Position(1) = 4; f5.Position(2) = 4;

f6 = figure; 
ba_image(gp_grains)

f7 = figure; 
ba_image(gp_ptc)
f7.Position(1) = 4;
hold on; 


%% Grain-grain angles per boundary pixel 
if ~isempty(gp_mfv.grain_border_angles)
    f8 = figure; histogram(real(gp_mfv.grain_border_angles(:,5)), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    function_show_border_angles(gp_mfv, gp_mfv.grain_border_angles);
    f8.Color = 'white'; f8.Units = 'inches'; f8.Position(3) = 2.75; f8.Position(4) = 2.25;
end

%% Image Quality histograms
ptc_map = (gp_ptc.ptc_map > 0);
grain_map = (gp_grains.ptc_map > 0);
webbing_map = ptc_map & ~grain_map;

% image_quality, combine
fff = figure;
iq_histos(img_quality2(ptc_map));
iq_histos(img_quality2(grain_map));
iq_histos(img_quality2(webbing_map));

% Separate
fff1 = figure; 
h1 = iq_histos(img_quality2(ptc_map)); h1.FaceColor = 'black';
fff1.Position(1) = 3;

fff2 = figure; 
h2 = iq_histos(img_quality2(grain_map)); h2.FaceColor = 'black';
fff2.Position(1) = 5;

fff3 = figure; 
h3 = iq_histos(img_quality2(webbing_map)); h3.FaceColor = 'black';
fff3.Position(1) = 7;

%% Mask for grain_map
ffff = figure; ffff.Units = 'inches';
imshow((~grain_map))
ffff.Position = [7,1,2.75,2.25];

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
    fighandles(n).Units = 'inches';
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
    ax_current.FontName = 'Arial';
end

function plot_igba(M)
    histogram(M.intragrain_border_angles(:,5), 72)
    xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    f = gcf; f.Units = 'inches'; f.Position = [1,1,2.75,2.25];
end

function ba_image(M)
    function_show_border_angles(M, M.intragrain_border_angles);
    f = gcf; f.Units = 'inches'; f.Position = [1,1,2.75,2.25];
end

function h = iq_histos(M)
    f = gcf; f.Units = 'inches'; f.Position = [1 1 1.9 3];
    h = histogram(M); hold on;
    xlim([6 13]*1e4); ylim([0 12000]);
    xlabel('iq'); ylabel('count')
    h.EdgeColor = 'none';
end
