%% About
% This script is to create Figure 8 in The application of electron 
% backscatter diffraction for investigating intra-particle grain
% architectures and boundaries in lithium ion electrodes

%% Setup
close all; clear; clc;
addpath('Visualization')
addpath('GrainProps Outputs')
addpath('Inputs')
addpath('Processing')

%% Loading
% grains only
load('gp_grains_only.mat'); close all;
gp_grains = grain_props;

% FULL particle. cleaning applied
load('gp_ptc_grains_identified_by_grouping.mat'); close all;
gp_ptc = grain_props;

ebsd_img = imread('DF-NMC-CF-01-e_03.tif');

%% Color maps for impact of cleaning
f1 = figure; imshow(show_removed_noise(gp_grains));
fig_set();

f2 = figure; imshow(show_removed_noise(gp_ptc)); 
fig_set();

%% Red-white intragrain misorientations
f3 = figure; imshow(show_intragrain_misorientation(gp_grains)); 
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

%% Histograms and maps - Intra-grain angles per boundary pixel
f5 = figure; hold on;
igba_histos(gp_ptc);
f5.Position(1) = 4; f5.Position(2) = 4;

f6 = figure; 
ba_image(gp_grains)

f7 = figure; 
ba_image(gp_ptc)
f7.Position(1) = 4;

% Mask for grain_map
f12 = figure; f12.Units = 'inches';
imshow((grain_map))
f12.Position = [7,1,2.75,2.25];

[angles_b, angles_g] = count_gig_boundaries(gp_ptc, boundary_map);

ff2 = figure; hold on;
igba_histos_gen(angles_g); ff2.Position(1) = 1; ff2.Position(2) = 4;

ff1 = figure; hold on;
igba_histos_gen(angles_b); ff1.Position(1) = 7; ff1.Position(2) = 4;

%% Intragrain fractions
[g_sz, ig_f, ig_ft, g_szt] = count_ig_fractions(gp_grains);

% individual intra-grains
f13 = figure; scatter(g_sz, ig_f, 3, 'filled');
fig_set(); xlabel('Grain size (\mum^2)'); ylabel('f_{individual}')
f13.Position(3:4) = [2.05, 1.7];

% total fraction of intragrains
f14 = figure; scatter(g_szt, ig_ft, 8, 'filled');
fig_set(); xlabel('Grain size (\mum^2)'); ylabel('f_{total}')
f14.Position(3:4) = [2.05, 1.7];

%% Saving
save_format = 'svg'; % svg, png

% misorientations
saveas(f3, 'Figures/8_intragrain_misorientations', save_format)

%iq
saveas(f8,  'Figures/8_iq_combined', save_format)
saveas(f9,  'Figures/8_iq_particle', save_format)
saveas(f10, 'Figures/8_iq_grains', save_format)
saveas(f11, 'Figures/8_iq_boundaries', save_format)

% maps
saveas(f6,  'Figures/8_gmisorientation_map_grains', save_format)
saveas(f7,  'Figures/8_gmisorientation_map_ptc', save_format)
saveas(f12, 'Figures/8_gmisorientation_map_boundaries', save_format)

% histograms
saveas(f5,   'Figures/8_histogram_particle', save_format)
saveas(ff2,  'Figures/8_histogram_grains', save_format)
saveas(ff1,  'Figures/8_histogram_boundaries', save_format)

%fractions
saveas(f13,  'Figures/8_fractions_individual', save_format)
saveas(f14,  'Figures/8_fractions_total', save_format)


%% Plot Help Functions
function igba_histos(M)
% intergrain boundary angle histograms
    igba_histos_gen(M.intragrain_border_angles(:,5))
end

function igba_histos_gen(M)
% intergrain boundary angle histograms
    hold on;
    angle_ = rand_ori_hist(length(M), 1);
    h_theory1 = histogram(angle_, 45); h_theory1.EdgeColor = 'none';
    h = histogram(M, 45); h.EdgeColor = 'none';
    xlabel('g-misorientation (degrees)'); ylabel('Count (pixel edges)')
    f = gcf; f.Units = 'inches'; f.Position = [1,1,2.75,2.25];
    f.Color = 'white';
    ylim([0, 5000])
    hold off;
end

function ba_image(M)
% boundary angle maps
    show_border_angles(M, M.intragrain_border_angles);
    f = gcf; f.Units = 'inches'; f.Position = [1,1,2.75,2.25];
    f.Color = 'white'; 
end

function h = iq_histos(M)
% histograms for iq values
    f = gcf; f.Units = 'inches'; f.Position = [1 1 1.6 2.25];
    f.Color = 'white'; 
    h = histogram(M, 50); hold on;
    h.NumBins
    xlim([6 13]*1e4); ylim([0 3.2e4]);
    xlabel('iq'); ylabel('Count (pixels)')
    ax = gca; ax.FontSize = 8;
    ax.Box = 'off';
    h.EdgeColor = 'none';
end

function fig_set()
    f = gcf;
    f.Color = 'white'; 
    f.Units = 'inches'; 
    f.Position(3:4) = [2.75, 2.25];
    f = gca; f.FontSize = 7;
end
