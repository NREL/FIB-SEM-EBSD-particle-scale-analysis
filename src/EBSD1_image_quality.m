%% About
% This script is to create an image quality map that can be used in the
% Weka segmentation.
addpath('Inputs')
addpath('Segmentation')
 
%% Inputs
txt = 'DF-NMC-CF-01-e_03_Cleaned_All data.txt';
img = 'DF-NMC-CF-01-e_03.tif';
output = 'test';
save_file = false;

%% Loading
ebsd_text = import_ebsd(txt); % ebsd text file
ebsd_img = imread(img); % for size of related ebsd img

% interpolated image
[~, ~, ~, iq, ~] = intpol_ebsd(ebsd_text, ebsd_img);

% show image quality map
figure; imshow(iq./max(iq,[],'all'));

if save_file
    imwrite(iq./max(iq,[],'all'), ['output', '.tif'], 'TIFF');
end