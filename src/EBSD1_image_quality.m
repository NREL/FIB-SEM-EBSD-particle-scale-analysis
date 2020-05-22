%% About
% This script is to create an image quality map that can be used in the
% Weka segmentation.
addpath('Inputs')

%% Inputs
txt = 'DF-NMC-CF-01-e_03_Cleaned_All data.txt';
img = 'DF-NMC-CF-01-e_03.tif';
output = 'test';
save_file = true;

%% Loading
ebsd_text = function_import_ebsd_text(txt); % ebsd text file
ebsd_img = imread(img); % for size of related ebsd img

% interpolated image
[~, ~, ~, iq, ~] = function_interpolate_random_ebsd_text(ebsd_text, ebsd_img);

% show image quality map
figure; imshow(iq./max(iq,[],'all'));

if save_file
    imwrite(iq./max(iq,[],'all'), ['output', '.tif'], 'TIFF');
end