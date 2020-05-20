%% Description
% The following code guides the user through the segmentation and cleaning
% process to achieve an image with segmented grains which are adjacent to
% each other. 
close all; clear; clc;

% Last results for e_03
% Webbing to keep: 45
% Grain area threshold: 250
% Background to keep: 1
% Labels to remove: [3 22 14 25 9 12]

%% Test Files
seg_map_filename = 'avg_interpol_seg1.tiff';
ebsd_text_filename = 'DF-NMC-CF-01-e_03_Cleaned_All data.txt';

%% Load Data
seg_map_iq = imread(seg_map_filename); % segmentation
seg_map_iq = imresize(seg_map_iq, 1); % resize if needed
ebsd_text_data = function_import_ebsd_text(ebsd_text_filename); % EBSD txt file

%% Check to make sure 1=webs, 2=grains
function_bwshowlabels(seg_map_iq, 'first')
% seg_map_iq = function_swap_labels(seg_map_iq,1,2); % swap labels until correct if needed

%% Determine which webs to keep/remove
struct_el = strel('disk', 4);
fig_web = function_show_web(seg_map_iq, 'ShowLabels', false);
fig_web_labels = function_show_web(seg_map_iq);  % determine which webs to remove
fig_web_labels = function_show_web(seg_map_iq, 4);  % determine which webs to remove

%% Keep webbings
inp = input('Input webbing numbers to keep ([1,2,66...]): ');
[BW_iq_web, BW_cleaned_not_eroded] = function_clean_web(seg_map_iq, inp, struct_el);
figure; imshow(label2rgb(BW_cleaned_not_eroded))

%% Determine which grains to keep/remove
fig_grains = function_show_grains(seg_map_iq, 'ShowLabels', false); % all grains

inp2 = 1;
while inp2 == 1
    inp3 = input('Input area threshold (in pixels^2): ');
    [fig_grains_thresholded, thresholded_grain_lbls] = function_show_grains(seg_map_iq, inp3); % determine which grains to remove
    inp2 = input('1+enter to try again, enter only to move on: ');
end

%% Remove Grains by Threshold Using Above Input
BW_iq = function_clean_grains(seg_map_iq, thresholded_grain_lbls);% threshold grains, repalce with NaNs

%% Combine Webbings
BW_iq_comb = function_combine_grains_webs(BW_iq, BW_iq_web); % combined grain/webs, replace NaNs with webbing
figure; imshow(label2rgb(BW_iq_comb))

%% Show backgrounds
function_show_backgrounds(BW_iq_comb);
function_show_backgrounds(BW_iq_comb, 5);

%% Decide Which Background to Keep
inp4 = input('Input background labels to keep ([1,2,4...]): ');
[BW_iq_comb_clean, fig_BW_rdy_seg] = function_bckgrnd_to_web(BW_iq_comb, inp4); % clean created background 'particles', replace 0 with webbing

%% Dilation and Segmentation
[new_BW_iq, BW_seq] = function_remove_web(BW_iq_comb_clean); % dilation into webbing
figure; montage(BW_seq) %% shows segmentation steps

%% Remove labels of choice
function_bwshowlabels(new_BW_iq, 'centroid'); % show labels of all particles
inp5 = input('Labels to remove ([4,6,18...]): ');
BW_final = function_bwremovelabels(new_BW_iq, inp5); % remove labels and normalize remaining

%% show remaining image
function_bwshowlabels(BW_final, 'centroid'); % show labels of all particles

%% Print values to use in other script
fprintf('\n--Parameters for cleaning--')
fprintf(['Webbing to keep: ', mat2str(inp), '\n']);
fprintf('Grain area threshold: %.0f\n', inp3);
fprintf(['Background to keep: ', mat2str(inp4), '\n']);
fprintf(['Labels to remove: ', mat2str(inp5), '\n']);

%% All figures stacked
gr_root = groot;
figs = get(groot, 'Children');
for n = 1:length(figs)
    figs(n).Units = 'inches';
    figs(n).Position = 2.*[1/2, 1/2, 2.5, 2.75];
    figure(figs(n))
end
error('end here')

%% Order all figures
gr_root = groot;
figs = get(groot, 'Children');
sqr_spread = ceil(sqrt(length(figs)));
spread_fct = 1.3;
x_div = gr_root.ScreenSize(3)/sqr_spread/spread_fct;
y_div = gr_root.ScreenSize(4)/sqr_spread/spread_fct;
for n = 1:length(figs)
    pos = [x_div*(mod(n,sqr_spread))+1, y_div*(floor((n-1)/sqr_spread))+1, x_div/spread_fct, y_div/spread_fct];
    figs(n).Position = pos;
    figure(figs(n))
end