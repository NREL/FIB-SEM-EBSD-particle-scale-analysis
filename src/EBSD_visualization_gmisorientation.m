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
[g_sz, ig_f, ig_ft, g_szt] = count_ig_fractions(gp_grains);

% individual intra-grains
f_ig1 = figure; scatter(g_sz, ig_f, 3, 'filled');
f_ig1.Color = 'white'; f_ig1.Units = 'inches'; f_ig1.Position(3:4) = [2.75, 2.25];
xlabel('Grain size (\mum)'); ylabel('f_{individual}')
a_intg_fran = gca; a_intg_fran.FontSize = 10;

% total fraction of intragrains
f_ig2 = figure; scatter(g_szt, ig_ft, 8, 'filled');
f_ig2.Color = 'white'; f_ig2.Units = 'inches'; f_ig2.Position(3:4) = [2.75, 2.25];
xlabel('Grain size (\mum)'); ylabel('f_{total}')
f_ig2 = gca; f_ig2.FontSize = 10;


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
