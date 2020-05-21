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

% most frequency orientation adopted - already created and works, move to
% SI stuffs
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
fig_set();

f2 = figure; imshow(function_view_speckle_removed(gp_ptc)); 
fig_set();

%% Red-white intragrain misorientations
f3 = figure; imshow(function_view_intragrain_misorientation(gp_grains)); 
fig_set();

%% Image Quality histograms
ptc_map = (gp_ptc.ptc_map > 0);
grain_map = (gp_grains.ptc_map > 0);
boundary_map = ptc_map & ~grain_map;

% image_quality, combine
f8 = figure;
iq_histos(img_quality2(ptc_map));
iq_histos(img_quality2(grain_map));
iq_histos(img_quality2(boundary_map));

% Separate
f9 = figure; 
h1 = iq_histos(img_quality2(ptc_map)); h1.FaceColor = 'black';
f9.Position(1) = 3;

f10 = figure; 
h2 = iq_histos(img_quality2(grain_map)); h2.FaceColor = 'black';
f10.Position(1) = 5;

f11 = figure; 
h3 = iq_histos(img_quality2(boundary_map)); h3.FaceColor = 'black';
f11.Position(1) = 7;

%% Intra-grain angles per boundary pixel
f5 = figure; 
igba_histos(gp_ptc);
f5.Position(1) = 4; f5.Position(2) = 4;

f6 = figure; 
ba_image(gp_grains)

f7 = figure; 
ba_image(gp_ptc)
f7.Position(1) = 4;
hold on;

% Mask for grain_map
f12 = figure; f12.Units = 'inches';
imshow((grain_map))
f12.Position = [7,1,2.75,2.25];

[angles_b, angles_g] = count_gig_boundaries(gp_ptc, boundary_map);
ff2 = figure; igba_histos_gen(angles_g); ff2.Position(1) = 1; ff2.Position(2) = 4;
ff1 = figure; igba_histos_gen(angles_b); ff1.Position(1) = 7; ff1.Position(2) = 4;

%% Intragrain fractions
[g_sz, ig_f, ig_ft, g_szt] = count_ig_fractions(gp_grains);

% individual intra-grains
f13 = figure; scatter(g_sz, ig_f, 3, 'filled');
fig_set(); xlabel('Grain size (\mum)'); ylabel('f_{total}')

% total fraction of intragrains
f14 = figure; scatter(g_szt, ig_ft, 8, 'filled');
fig_set(); xlabel('Grain size (\mum)'); ylabel('f_{total}')

%% Grain-grain angles per boundary pixel - move to SI
if ~isempty(gp_mfv.grain_border_angles)
    f100 = figure; histogram(real(gp_mfv.grain_border_angles(:,5)), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    function_show_border_angles(gp_mfv, gp_mfv.grain_border_angles);
    f100.Color = 'white'; f100.Units = 'inches'; f100.Position(3) = 2.75; f100.Position(4) = 2.25;
end

%% Plot Help Functions
function igba_histos(M)
% intergrain boundary angle histograms
    igba_histos_gen(M.intragrain_border_angles(:,5))
end

function igba_histos_gen(M)
% intergrain boundary angle histograms
    h = histogram(M, 45); h.EdgeColor = 'none';
    xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    f = gcf; f.Units = 'inches'; f.Position = [1,1,2.75,2.25];
    f.Color = 'white';
    ylim([0, 5000])
end

function ba_image(M)
% boundary angle maps
    function_show_border_angles(M, M.intragrain_border_angles);
    f = gcf; f.Units = 'inches'; f.Position = [1,1,2.75,2.25];
end

function h = iq_histos(M)
% histograms for iq values
    f = gcf; f.Units = 'inches'; f.Position = [1 1 1.9 3];
    h = histogram(M); hold on;
    xlim([6 13]*1e4); ylim([0 12000]);
    xlabel('iq'); ylabel('count')
    h.EdgeColor = 'none';
end

function fig_set()
    f = gcf;
    f.Color = 'white'; 
    f.Units = 'inches'; 
    f.Position(3:4) = [2.75, 2.25];
    f = gca; f.FontSize = 10;
end
