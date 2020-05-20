%% Description
% The following code guides the user through the segmentation and cleaning
% process to achieve an image with segmented grains which are adjacent to
% each other. 

close all; clear; clc;
addpath('Segmentation')

%% Inputs
s.seg_map_filename = 'avg_interpol_seg1.tiff';
s.scale = 1/8;
s.um_per_pix = 1/(144-18); % pixel scaling
s.struct_el = strel('disk', 4); % for boundary cleaning

%% Call guiding function
op = segmentation_parameters(s);

%% Plot Figures
figure; imshow(label2rgb(op.ogsegmentation))
figure; function_bwshowlabels(op.ogsegmentation, 'first')
figure; function_show_web(op.ogsegmentation, 'ShowLabels', false);
figure; function_show_web(op.ogsegmentation, 4);
figure; imshow(label2rgb(op.cleaned_webbing))
figure; imshow(label2rgb(op.cleaned_webbing_closed))
figure; function_show_grains(op.ogsegmentation, 0, 'ShowLabels', false); % all grains
figure; imshow(label2rgb(op.thresholded_grains))
figure; imshow(label2rgb(op.boundary_grain_combined))
figure; imshow(label2rgb(op.boundary_grain_combined_cleaned)) % prior to dilation
figure; montage(op.dilation_sequence) %% shows segmentation steps
figure; function_bwshowlabels(op.dilated_final, 'centroid');
figure; imshow(label2rgb(op.final))
figure; function_bwshowlabels(op.final, 'centroid'); % show labels of all particles

%% Stack figures
gr_root = groot;
figs = get(groot, 'Children');
for n = 1:length(figs)
    figs(n).Units = 'inches';
    figs(n).Position = 2.*[1/2, 1/2, 2.5, 2.75];
    figure(figs(n))
end
