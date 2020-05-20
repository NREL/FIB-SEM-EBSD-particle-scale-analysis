function output = segmentation_parameters(struct)
seg_map_filename = struct.seg_map_filename;
scale = struct.scale;
um_per_pix = struct.um_per_pix;
struct_el = struct.struct_el;

%% Load Data
seg_map_iq = imread(seg_map_filename);
seg_map_iq = imresize(seg_map_iq, scale);

%% Verify 1 = boundaries, 2 = grains
function_bwshowlabels(seg_map_iq, 'first')
b_reg = input('Which # is the boundary region (1 or 2)?\n'); close all;
if b_reg == 2
    seg_map_iq = function_swap_labels(seg_map_iq,1,2); 
end
    
%% Determine which webs to keep/remove
figure; subplot(1,2,1); 
function_show_web(seg_map_iq, 'ShowLabels', false);
title('All boundaries')

subplot(1,2,2); 
function_show_web(seg_map_iq, 4);  % determine which webs to remove
title('4 Largest boundaries')

disp('Showing boundary regions')

inp = input('Input webbing numbers to keep ([1,2,66...]): '); close all;
[BW_iq_web, BW_cleaned_not_eroded] = function_clean_web(seg_map_iq, inp, struct_el);

%% Determine which grains to keep/remove
figure; function_show_grains(seg_map_iq, 'ShowLabels', false); % all grains

inp2 = 1;
while inp2 == 1
    inp3 = input('Input area threshold (in pixels^2): '); close all; figure;
    thresholded_grain_lbls = function_show_grains(seg_map_iq, inp3, 'ShowLabels', false); % determine which grains to remove
    inp2 = input('1 to try again, enter only to move on: ');
end

%% Remove Grains by Threshold Using Above Input
BW_iq = function_clean_grains(seg_map_iq, thresholded_grain_lbls);% threshold grains, repalce with NaNs

%% Combine Grain and Boundaries
BW_iq_comb = function_combine_grains_webs(BW_iq, BW_iq_web); % combined grain/webs, replace NaNs with webbing
figure; imshow(label2rgb(BW_iq_comb))
input('Showing combined grain/boundaries.\n Enter to continue.\n')

%% Show backgrounds and decide which to keep
figure; subplot(1,2,1)
function_show_backgrounds(BW_iq_comb, 'ShowLabels', false);
title('All background')

subplot(1,2,2)
function_show_backgrounds(BW_iq_comb, 5, 'ShowLabels', true);
title('5 largest background regions')

disp('Showing backgrounds.')
inp4 = input('Input background labels to keep ([1,2,4...]): '); 
close all;

% cleaned output ready for dilation
BW_iq_comb_clean = function_bckgrnd_to_web(BW_iq_comb, inp4);

%% Dilation and Boundary Removal
[new_BW_iq, BW_seq] = function_remove_web(BW_iq_comb_clean); % dilation into webbing
title('final dilated grains')

%% Remove Labels of choice
figure;
function_bwshowlabels(new_BW_iq, 'centroid'); % show labels of all particles
inp5 = input('Labels to remove ([4,6,18...]): '); 
close all;

figure;
BW_final = function_bwremovelabels(new_BW_iq, inp5); % remove labels and normalize remaining
imshow(label2rgb(BW_final))


%% Print values to use in other script
fprintf('\n--Parameters for cleaning--\n\n')
fprintf(['Webbing to keep: ', mat2str(inp), '\n']);
fprintf('Grain area threshold: %.0f\n', inp3);
fprintf(['Background to keep: ', mat2str(inp4), '\n']);
fprintf(['Labels to remove: ', mat2str(inp5), '\n']);
fprintf('\n---------------------------\n\n')

%% Montage
% figure; imshow(label2rgb(seg_map_iq))
% figure; function_bwshowlabels(seg_map_iq, 'first')
% figure; function_show_web(seg_map_iq, 'ShowLabels', false);
% figure; function_show_web(seg_map_iq, 4);
% figure; imshow(label2rgb(BW_cleaned_not_eroded))
% figure; imshow(label2rgb(BW_iq_web))
% figure; function_show_grains(seg_map_iq, 0, 'ShowLabels', false); % all grains
% figure; imshow(label2rgb(BW_iq))
% figure; imshow(label2rgb(BW_iq_comb))
% figure; imshow(label2rgb(BW_iq_comb_clean)) % prior to dilation
% figure; montage(BW_seq) %% shows segmentation steps
% figure; function_bwshowlabels(new_BW_iq, 'centroid');
% figure; imshow(label2rgb(BW_final))
% figure; function_bwshowlabels(BW_final, 'centroid'); % show labels of all particles

%% output
output = struct();

output.ogsegmentation = seg_map_iq;
output.cleaned_webbing = BW_cleaned_not_eroded;
output.cleaned_webbing_closed = BW_iq_web;
output.thresholded_grains = BW_iq;
output.boundary_grain_combined = BW_iq_comb;
output.boundary_grain_combined_cleaned = BW_iq_comb_clean;
output.dilation_sequence = BW_seq;
output.dilated_final = new_BW_iq;
output.final = BW_final;

end