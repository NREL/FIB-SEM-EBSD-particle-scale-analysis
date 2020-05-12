clear; close all; clc;

%% Saving
% time stamp appended to end of filename
filename = 'EBSD_03_run1';
save_mat = true; % true: creates Matlab data file of everything
save_excel = true; % true: creates excel form of grain_props

%% Inputs
% segmentation and EBSD data
seg_map_fn = 'avg_interpol_seg1.tiff'; % This segmentation determines um_per_pix
ebsd_text_fn = 'DF-NMC-CF-01-e_03_Cleaned_All data.txt';

% scaling
scale = 1/8; % length scale - smaller scales = faster processing
um_per_pix = 1/(144-18); % pixel scaling, here for IPF map of 1031 x 1024

% Segmentation to extract these values 
boundary_lbls = [9]; % green region, use 9,13,23,45 for 1/8, 1/4, 1/2, 1 scale respectively
bckgrd_lbls = [1]; %  red region
remove_lbls = [2,3,4,5,6,7,206,194]; % remove grains outside secondary particle
A_thresh_um = 0.016; % [=] um^2, threshold for what is considered a grain
CI_thres = -0.01; % 1-CI_thresh is confidence interval, if < 0 all data used
mult_secondary_ptcs = false; % if secondary particles in segmentation map

% Cleaning
angle_threshold = 1.8; % [=] degrees
fill_grain = false; % true: N_thresh_um ignored & most common orientation fills grain
N_thresh_um = 0.01; % [=] um^2, minimum size of speckle to remove

%% Processing
% No inputs necessary below.

%% Unit conversions
grain_props.um_per_pix = um_per_pix/scale;
A_thresh_pix = A_thresh_um/(grain_props.um_per_pix^2); % area threshold in pixels
N_thresh_pix = N_thresh_um/(grain_props.um_per_pix^2);

%% Load Image Quality Weka Segmentation and EBSD Text File
seg_map = imread(seg_map_fn); % segmentation
seg_map = imresize(seg_map, scale, 'nearest');
ebsd_text = function_import_ebsd_text(ebsd_text_fn); % EBSD txt file
function_bwshowlabels(seg_map, 'first')

%% Process Segmentation
disk_size = floor(4*scale^2); % cleans boundaries, ...might be unnecessary
struct_el = strel('disk', disk_size);
fig_web = function_show_web(seg_map, 'ShowLabels', false);
fig_web_labels = function_show_web(seg_map, 2);  % determine which webs to remove

fig_grains = function_show_grains(seg_map, 'ShowLabels', false);
[fig_grains_thresholded, thresholded_grain_lbls] = function_show_grains(seg_map, A_thresh_pix); % determine which grains to remove

[BW_iq_web, BW_cleaned_web] = function_clean_web(seg_map, boundary_lbls, struct_el);

BW_iq = function_clean_grains(seg_map, thresholded_grain_lbls);% threshold grains, repalce with NaNs
BW_iq_comb = function_combine_grains_webs(BW_iq, BW_iq_web); % combined grain/webs, replace NaNs with webbing

[fig_new_background, fig_og_backgrounds] = function_show_backgrounds(BW_iq_comb, 1);

[BW_iq_comb_clean, fig_BW_rdy_seg] = function_bckgrnd_to_web(BW_iq_comb, bckgrd_lbls); % clean created background 'particles', replace 0 with webbing
[new_BW_iq, BW_seq] = function_remove_web(BW_iq_comb_clean); % dilation into webbing
figure; montage(BW_seq) %% shows segmentation steps

new_BW_iq(new_BW_iq == 1) = 0; % cleaning for leftover segmentation boundaries
function_bwshowlabels(new_BW_iq, 'centroid'); % show labels of all particles

BW_final = function_bwremovelabels(new_BW_iq, remove_lbls); % remove labels and normalize remaining
function_bwshowlabels(BW_final, 'centroid'); % show labels of all particles
grain_props.BW = BW_final; % sequentially numbered BWs

%% CI, EBSD Euler Extracted
% confidence interval map
[~, ~, ~, img_quality2, CIs] = function_interpolate_random_ebsd_text(ebsd_text, seg_map, 'mode', 'average');
CI_map = (CIs > CI_thres);
grain_props.CI = CI_map; % 1 on these maps means ok to use

% Euler data (phi1, cap_phi, phi2)
[phi1, cap_phi, phi2, image_quality] = function_interpolate_random_ebsd_text(ebsd_text, seg_map, 'mode', 'random');
euler_data = cat(3, phi1, cap_phi, phi2);
grain_props.euler = euler_data; % 3 layer data with phi1, cap_phi, phi2 (Bunge Euler Convention)

% Z-direction calculation, normalization for picture, and theta-phi map
[xyzz, xyz_pos] = function_get_001xyz(euler_data);
th_phi_mat = function_xyzmat2sphmat(xyz_pos);
grain_props.tp_mat = th_phi_mat;
grain_props.xyz_pos = xyz_pos;

%% Property Calculations
grain_props = function_secondary_particle_data(grain_props, mult_secondary_ptcs); % shouldn't need CI map

[grain_props, border_composite] = function_grain_borders(grain_props); % uses CI

grain_props = function_grain_properties(grain_props); % implementation of region props - uses CI
grain_props = function_grain_distances(grain_props); % distances from centroids to some defined distance map (here to edges of particles)

[grain_props, gr_time] = function_grouping(grain_props, angle_threshold); % z-axis cleaning tolerance grouping and 4-connectivity cleaning
grain_props = function_cleaning(grain_props, N_thresh_pix, fill_grain);

grain_props = function_boundary_angles(grain_props); % border angles - fix position names, what about real(deg)??

grain_props = function_intragrain_borders(grain_props); % acquisition just like boundary function_grain_borders
grain_props = function_intragrain_boundary_angles_raster(grain_props); % angles of intra-grains only

grain_props = function_intragrain_properties(grain_props);

%% Visualize Cleaning Result
figure; imshow(function_mat2col(grain_props.xyz_cleaned));

%% Save Data
if save_mat
    % Matlab data file
    dt = datetime; dt.Format = 'uuuu-MM-dd-HH-mm-ss';
    ctime = char(dt);
    save_name = [ctime, '_', filename, '.mat'];
    save(save_name)
end
if save_excel
    % Create and Save Tables
    [T_pt, ptc_info, T_g, T_ig] = create_grain_info_tables(grain_props);
    save_name_excel = [save_name(1:(end-4)), '.xlsx'];
    writetable(T_pt, save_name_excel, 'Sheet', 'pixels');
    writecell(ptc_info, save_name_excel, 'Sheet', 'particle');
    writetable(T_g, save_name_excel, 'Sheet', 'grain');
    writetable(T_ig, save_name_excel, 'Sheet', 'intragrain');
end

