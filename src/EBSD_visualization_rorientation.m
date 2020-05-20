%% About
%

%% Setup
close all; clear; clc;
addpath('Visualization')

%% Loading/Inputs
load('2020-01-12-14-20-15_EBSD_03_run1'); close all;
ebsd_img = imread('DF-NMC-CF-01-e_03.tif');
ptc_r105090 = [7.1, 9.3, 12.1]./2; % in microns, spread of particle diameters

%% Angle of Orientations Relative to Radial Direction - varied particle diameter
% FUNCTIONALIZE THIS
for n = 1:length(ptc_r105090)
    ptc_cntrd = [grain_props.ptc_centroid, 0];
    rslice = sqrt(grain_props.ptc_area*(grain_props.um_per_pix^2)/pi); % um ^2
    if rslice < ptc_r105090(n)
        roffset = sqrt(ptc_r105090(n)^2 - rslice^2); % um
    else
        roffset = 0;
    end
    angles_to_r{n} = function_hist_rs(grain_props, -roffset);
%     angles_to_r{n} = function_hist_rs(grain_props, roffset);
    r_mis_pixel_map_pos{n} = function_map_rmisorientation(grain_props, roffset);
    r_mis_pixel_map_neg{n} = function_map_rmisorientation(grain_props, -roffset);
end

fig_rad_dir_ptc_d = figure; fig_rad_dir_ptc_d.Color = 'white';
fig_rad_dir_ptc_d.Units = 'inches'; fig_rad_dir_ptc_d.Position(3) = 2; fig_rad_dir_ptc_d.Position(4) = 2.75;

h = histogram(angles_to_r{2}, 18);
ylabel('# grains with orientation')
xlabel('Radial misalignment (degrees)')
[n1, edges] = histcounts(angles_to_r{1}, 18);
[n3, ~] = histcounts(angles_to_r{3}, 18);
hold on;
err = errorbar(0.5*(edges(1:end-1) + edges(2:end)), h.Values, h.Values-min([n1;n3]), max([n1;n3])-h.Values); err.LineStyle = 'none'; err.Color = [0 0 0];
% ylim([0 50]); xlim([0 90])
a = gca; a.FontSize = 8;

%% Colormaps of g-orientation
figure; imshow(mat2gray(90 - r_mis_pixel_map_pos{3})); f_r_mis1 = gcf; f_r_mis1.Units = 'inches'; f_r_mis1.Position = [5.7396 2.4063 4.2 4.1];
figure; imshow(mat2gray(90 - r_mis_pixel_map_neg{3})); f_r_mis2 = gcf; f_r_mis2.Units = 'inches'; f_r_mis2.Position = [5.7396 2.4063 4.2 4.1];
figure; surf([0,90; 0,90], [0, 90; 0,90], [0,90; 0,90]); colorbar(); colormap(flip(gray))

%% Figure Modifications
fighandles = findobj('Type', 'figure');
for n = 1:length(fighandles)
    fighandles(n).Color = 'white';
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
end
