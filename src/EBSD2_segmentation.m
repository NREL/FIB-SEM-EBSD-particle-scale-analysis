%% Description
% The following code guides the user through the segmentation and cleaning
% process to achieve an image with segmented grains which are adjacent to
% each other. 
close all; clear; clc;
addpath('Segmentation')
addpath('Inputs')

%% Inputs
s.seg_map_filename = 'e03_weka.tiff';
s.scale = 1;
s.um_per_pix = 1/(144-18); % pixel scaling
s.struct_el = strel('disk', 4); % for boundary cleaning

%% Segmentation Procedure Walkthrough
op = segmentation_parameters(s);

%% Plot Figures
figure; imshow(label2rgb(op.ogsegmentation))
figure; bwshowlabels(op.ogsegmentation, 'first')
figure; show_seg_boundary(op.ogsegmentation, 'ShowLabels', false);
figure; show_seg_boundary(op.ogsegmentation, 4);
figure; imshow(label2rgb(op.cleaned_webbing))
figure; imshow(label2rgb(op.cleaned_webbing_closed))
figure; show_seg_grains(op.ogsegmentation, 0, 'ShowLabels', false); % all grains
figure; imshow(label2rgb(op.thresholded_grains))
figure; imshow(label2rgb(op.boundary_grain_combined))
figure; imshow(label2rgb(op.boundary_grain_combined_cleaned)) % prior to dilation
figure; montage(op.dilation_sequence) %% shows segmentation steps
figure; bwshowlabels(op.dilated_final, 'centroid');
figure; imshow(label2rgb(op.final))
figure; bwshowlabels(op.final, 'centroid'); % show labels of all particles

%% Stack figures
gr_root = groot;
figs = get(groot, 'Children');
for n = 1:length(figs)
    figs(n).Units = 'inches';
    figs(n).Position = 2.*[1/2, 1/2, 2.5, 2.75];
    figure(figs(n))
end
