%% About
% This script is to create Figure 7 in The application of electron 
% backscatter diffraction for investigating intra-particle grain
% architectures and boundaries in lithium ion electrodes

%% Setup
close all; clear; clc;
addpath('Visualization')
addpath('GrainProps Outputs')
addpath('Processing')

savefigs = true;

%% Loading/Inputs
load('gp_ptc_w_grains_cleaned_individually.mat'); close all;
ptc_r105090 = [7.1, 9.3, 12.1]./2; % in microns, spread of particle radii

%% Angle of Orientations Relative to Radial Direction - varied particle diameter
for n = 1:length(ptc_r105090)
    roffset = calc_roffset(grain_props, ptc_r105090(n));
    angles_to_r_above{n} = r_orientations(grain_props, roffset);
    angles_to_r_below{n} = r_orientations(grain_props, -roffset);
    r_mis_pixel_map_pos{n} = show_r_orientation(grain_props, roffset);
    r_mis_pixel_map_neg{n} = show_r_orientation(grain_props, -roffset);
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
f11 = figure;
angles = rand_ori_hist(length(angles_above{1}), 1);
h = histogram(angles, 18); hold on;
h.EdgeColor = 'none';

h2 = hist_clean(angles_above);
h2.FaceColor = [.3 .3 .3];

ylim('auto')
ylabel('pixels with orientation')
ax = gca; ax.Box = 'off';

angles_below = process_angle_map(grain_props, r_mis_pixel_map_neg);
f22 = figure;
h3 = histogram(angles, 18); hold on;
h3.EdgeColor = 'none';

h4 = hist_clean(angles_below);
h4.FaceColor = [.3 .3 .3];

ylim('auto')
ylabel('pixels with orientation')
ax = gca; ax.Box = 'off';

%% Colormaps of g-orientation
f3 = figure; imshow(mat2gray(90 - r_mis_pixel_map_pos{2})); 
f3.Units = 'inches'; f3.Position = [5.6 2.4 2.9 2.9];

f4 = figure; imshow(mat2gray(90 - r_mis_pixel_map_neg{2})); 
f4.Units = 'inches'; f4.Position = [9.9 2.4 2.9 2.9];

%% Saving
sv_fmt = 'svg';

if savefigs
    % histograms
    saveas(f11, 'Figures/7_histogram_rorientation_above', sv_fmt)
    saveas(f22, 'Figures/7_histogram_rorientation_below', sv_fmt)

    % maps
    saveas(f3, 'Figures/7_map_rorientation_above', sv_fmt)
    saveas(f4, 'Figures/7_map_rorientation_below', sv_fmt)
end

%% Plot Function
function h = hist_clean(M)
    f = gcf; 
    f.Color = 'white'; 
    f.Units = 'inches'; 
    f.Position = [1,2.4,2.2,2.4];
    
    h = histogram(M{2}, 18); hold on; 
    h.EdgeColor = [.4 .4 .4]; 
    h.EdgeAlpha = .5;
    
    ax = gca; ax.FontSize = 10;
    [n1, edges] = histcounts(M{1}, h.BinEdges);
    [n3, ~] = histcounts(M{3}, h.BinEdges);
   
    err = errorbar(0.5*(edges(1:end-1) + edges(2:end)), ...
        h.Values, h.Values-min([n1;n3;h.Values]), max([n1;n3;h.Values])-h.Values); 
    err.LineStyle = 'none'; err.Color = .1*ones(1,3);
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
