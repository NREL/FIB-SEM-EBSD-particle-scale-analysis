%% analysis using grain_props
close all; clear; clc;

% load grain_props
load('2020-01-12-14-20-15_EBSD_03_run1');

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
% ptc_r105090 = [8.5, 9.3, 10]./2; % in microns, 
second_ptc_r = 9.3/2; % microns, for radial adjustments
grain_props.pix2um = 1/(137-17); % micron per pixel

close all; %clearvars -except grain_props ptc_r105090 second_ptc_r


%% Edge Map
fig_edgemap = figure; im = image(grain_props.ptc_edge_map.*grain_props.pix2um);
fig_edgemap.Units = 'inches'; fig_edgemap.Position(3) = 3.0417; fig_edgemap.Position(4) = 2.25;
im.CDataMapping = 'scaled'; colorbar; colormap(jet)

%% Grain Border Map
fig_gbmp = figure; fig_gbmp.Units = 'inches';
imshow(grain_props.ptc_map); hold on;
for n = 1:length(grain_props.grain_boundaries)
    plot(grain_props.grain_boundaries{n}{1}(:,2), grain_props.grain_boundaries{n}{1}(:,1), 'Color', [0.5, 0.5, 0.5])
end
fig_gbmp.Position(3) = 2.75; fig_gbmp.Position(4) = 2.25;

%% Visualizaiton: Color maps for cleaning impact of cleaning
img_filtered_noise = function_view_speckle_removed(grain_props); % image cleaning - compares xyz_pos and xyz_cleaned
intragrain_misorientation = function_view_intragrain_misorientation(grain_props); % after cleaning - shows within each grain the levels of misorientation

figure; imshow(img_filtered_noise)
figure; imshow(intragrain_misorientation)

%% Visualizations: Show Intragrain Boundaries
figure; imshow(label2rgb(grain_props.BW)); hold on; 
for n = 1:length(grain_props.intragrain_boundaries)
    if iscell(grain_props.intragrain_boundaries{n})
        plot(grain_props.intragrain_boundaries{n}{1}(:,2), grain_props.intragrain_boundaries{n}{1}(:,1), 'k')
    end
end

%% Visualizations: Intra-grain angles per boundary pixel 
figure_intragrain_border_angles_histo = figure; histogram(grain_props.intragrain_border_angles(:,5), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
figure_intragrain_border_angles_histo.Color = 'white'; figure_intragrain_border_angles_histo.Units = 'inches'; figure_intragrain_border_angles_histo.Position(3) = 2.75; figure_intragrain_border_angles_histo.Position(4) = 2.25;
figure_intragrain_border_angles = function_show_border_angles(grain_props, grain_props.intragrain_border_angles);

%% Visualizations: Grain-grain angles per boundary pixel 
if ~isempty(grain_props.grain_border_angles)
    figure_grain_grain_border_angles_histo = figure; histogram(real(grain_props.grain_border_angles(:,5)), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    figure_grain_grain_border_angles_histo.Color = 'white'; figure_grain_grain_border_angles_histo.Units = 'inches'; figure_grain_grain_border_angles_histo.Position(3) = 2.75; figure_grain_grain_border_angles_histo.Position(4) = 2.25;
    figure_grain_grain_border_angles = function_show_border_angles(grain_props, grain_props.grain_border_angles);
end

%% Visualizations: Morphology - Francois' Function
if length(grain_props.grain_areas) > 1
%     results_d = function_prob_density_function_wrapper(grain_props.grain_areas); % wrapper for Francois' function
%     figure; plot(results_d.smoothed_probability_density_fct(:,1), results_d.smoothed_probability_density_fct(:,2))
%     figure; plot(results_d.probability_density_fct(:,1), results_d.probability_density_fct(:,2))
%     hold on; plot(results_d.smoothed_probability_density_fct(:,1), results_d.smoothed_probability_density_fct(:,2))
%     figure; histogram(grain_props.grain_areas)

%     [figure_freq_dist, figure_binned_dmap] = function_binned_dmap(grain_props, 4, 'area', label2rgb(grain_props.BW)); %
   [figure_freq_dist, figure_binned_dmap, dat] = function_binned_dmap(grain_props, 1, 'poa', mat2gray(grain_props.ptc_map)); %
end

figure_freq_dist.Position = [5.7396 2.4063 2.2604 2.3958];

figure(figure_binned_dmap)
hold on;
for n = 1:length(grain_props.grain_boundaries)
    plot(grain_props.grain_boundaries{n}{1}(:,2), grain_props.grain_boundaries{n}{1}(:,1), 'Color', [0.6, 0.6, 0.6])
end

%% Angle of Orientations Relative to Radial Direction - varied particle diameter
for n = 1:length(ptc_r105090)
    ptc_cntrd = [grain_props.ptc_centroid, 0];
    rslice = sqrt(grain_props.ptc_area*(grain_props.pix2um^2)/pi); % um ^2
    if rslice < ptc_r105090(n)
        roffset = sqrt(ptc_r105090(n)^2 - rslice^2); % um
    else
        roffset = 0;
    end
%     angles_to_r{n} = function_hist_rs(grain_props, -roffset);
    angles_to_r{n} = function_hist_rs(grain_props, roffset);
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

%% colormaps for orientation
figure; imshow(mat2gray(90 - r_mis_pixel_map_pos{3})); f_r_mis1 = gcf; f_r_mis1.Units = 'inches'; f_r_mis1.Position = [5.7396 2.4063 4.2 4.1];
figure; imshow(mat2gray(90 - r_mis_pixel_map_neg{3})); f_r_mis2 = gcf; f_r_mis2.Units = 'inches'; f_r_mis2.Position = [5.7396 2.4063 4.2 4.1];
figure; surf([0,90; 0,90], [0, 90; 0,90], [0,90; 0,90]); colorbar(); colormap(flip(gray))

%% Angle of Orientations Relative to Radial Direction - pixel by pixel

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
    'Subdivision', 3,...
    'ColorFaces', true, ...
    'PlotMethod', 'expansion', ... % default, (above is 
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
        curr_grn_size(count) = grn_size_n*(grain_props.pix2um^2);
        [r,c] = find(grain_props.BW_intragrain == rem(m)); % grain size
        curr_grn_frac(count) = length(r)*(grain_props.pix2um^2)/curr_grn_size(count);
        if curr_grn_frac(count) > 1; error('bigger than grain?'); end
    end
    srs = sortrows([curr_grn_size(:), curr_grn_frac(:)], 2, 'descend');
    srs(1,:) = []; % remove largest component of grain
    curr_grn_size = srs(:,1);
    curr_grn_frac = srs(:,2);
    
    grn_size = cat(1, grn_size, curr_grn_size(:));
    grn_frac = cat(1, grn_frac, curr_grn_frac(:));
    
    
    grn_frac_tot(n) = sum(curr_grn_frac); % total amount of grain that is not most frequent size
    grn_size_tot(n) = grn_size_n*(grain_props.pix2um^2);
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
%     fighandles(n).Position = [120 120 250 285];
    figure(fighandles(n));
    ax_current = gca;
    ax_current.FontSize = 10;
end
