function [phi1_intp, cap_phi_intp, phi2_intp, img_quality_intp, CI_intp] = function_interpolate_random_ebsd_text(ebsd_text_data, ebsd_img, varargin)
%function_interpolate_random_ebsd_text matches EBSD data to resolution of
%ebsd_img but fills in missing points in hexgaonl grid by random selection
%of neighbors, or by averaging
%   [phi1_intp, cap_phi_intp, phi2_intp, img_quality_intp, CI_intp] =
%   function_interpolate_random_ebsd_text(ebsd_text_data, ebsd_img,
%   varargin) takses the  array of ebsd_text_data, puts it in matrix form,
%   and reshapes its size with interpolation into the ebsd img. Note the
%   hexagonal data here can be managed.
%   
%   Inputs
%       ebsd_text_data - data array returned by function_import_ebsd_text
%       ebsd_img - image to match size of ebsd_text_data to
% 
%   Outputs
%       phi1_intp - matrix of phi1 values (rotation about Z axis)
%       cap_phi_intp - matrix of capital phi values (rotation about local
%           x axis)
%       phi2_intp - matrix of phi2 values (rotation about local z-axis)
%       img_quality_intp - image quality, a measure of the quality of the
%           kukuchi pattern at any spatial position
%       CI_intp - confidence interval, a map of where confidence exists in
%           the assigned orientation
%   
%    Optional parameters
%       'Mode' | 'average', 'random' - method of filling in hexagonal areas
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    %% Default Values
    default_mode = 'average';
    
    p = inputParser;
    addRequired(p, 'ebsd_text_data');
    addRequired(p, 'ebsd_img');
    addParameter(p, 'Mode', default_mode);
    parse(p,ebsd_text_data,ebsd_img,varargin{:});
    
    ebsd_text_data = p.Results.ebsd_text_data;
    ebsd_img = p.Results.ebsd_img;
    sample_mode = p.Results.Mode;
    
    %% Interpolate from hexagon to not   
    A = [ebsd_text_data{4}, ebsd_text_data{5}, ebsd_text_data{1}, ebsd_text_data{2}, ebsd_text_data{3}, ebsd_text_data{6}, ebsd_text_data{7}];
    ebsd_x = uniquetol(ebsd_text_data{4}); % uniqiue x-resolution points
    ebsd_y = uniquetol(ebsd_text_data{5}); % unique y-resolution points

    alpha = NaN(length(ebsd_y), length(ebsd_x)); % phi1 or phi or alpha
    beta =  NaN(length(ebsd_y), length(ebsd_x)); % PHI or  theta or beta
    gamma = NaN(length(ebsd_y), length(ebsd_x)); % phi2 psi or gamma
    image_quality = NaN(length(ebsd_y), length(ebsd_x)); % confidence interval
    CI = NaN(length(ebsd_y), length(ebsd_x)); % confidence interval
        
    for n = 1:length(A)
        [~, idx_x] = min(abs(ebsd_x - A(n,1)));
        [~, idx_y] = min(abs(ebsd_y - A(n,2)));
        alpha(idx_y, idx_x) = A(n,3);
        beta(idx_y, idx_x) = A(n,4);
        gamma(idx_y, idx_x) = A(n,5);
        image_quality(idx_y, idx_x) = A(n,6);
        CI(idx_y, idx_x) = A(n,7);
    end
    
    % ERROR HERE - CANNOT SCALE DOWN BECAUSE OF RANDOM WALK ON
    % NON-INDEPENDENT VARIABLES
    
    alpha = nanwalk(alpha, sample_mode);
    beta = nanwalk(beta, sample_mode);
    gamma = nanwalk(gamma, sample_mode);
    image_quality = nanwalk(image_quality, sample_mode);
    CI = nanwalk(CI, sample_mode);    

    % interpolate the 2D space now that all gaps are filled
    ebsd_img_res_x = linspace(ebsd_x(1), ebsd_x(end), size(ebsd_img, 2));
    ebsd_img_res_y = linspace(ebsd_y(1), ebsd_y(end), size(ebsd_img, 1));

    phi1_intp = interp2(ebsd_x, ebsd_y, alpha, ebsd_img_res_x', ebsd_img_res_y, 'nearest');
    cap_phi_intp = interp2(ebsd_x, ebsd_y, beta, ebsd_img_res_x', ebsd_img_res_y, 'nearest');
    phi2_intp = interp2(ebsd_x, ebsd_y, gamma, ebsd_img_res_x', ebsd_img_res_y, 'nearest');
    img_quality_intp = interp2(ebsd_x, ebsd_y, image_quality, ebsd_img_res_x', ebsd_img_res_y, 'nearest');
    CI_intp = interp2(ebsd_x, ebsd_y, CI, ebsd_img_res_x', ebsd_img_res_y, 'nearest');
end

function matrix = nanwalk(matrix, sample_mode) % replaces NaN's with random neighbor -> WARNING removes predictability of interpolation, but looks smoother
    rng('default'); % random generator CANNOT be random - find way to remove?
    for x = 1:size(matrix, 1)
        for y = 1:size(matrix, 2)
            if isnan(matrix(x,y))
                vals = [0,1; 1,0; 0,-1; -1, 0];

                % remove specific rows if an edge case
                if x == size(matrix, 1)
                    vals = vals(~ismember(vals,[1,0], 'rows'), :);
                end
                if x == 1
                    vals = vals(~ismember(vals,[-1,0], 'rows'), :);
                end
                if y == size(matrix, 2)
                    vals = vals(~ismember(vals,[0,1], 'rows'), :);
                end
                if y == 1
                    vals = vals(~ismember(vals,[0,-1], 'rows'), :);
                end
                
                if strcmpi(sample_mode, 'random')
                    pos_selector = randi(length(vals));
                    matrix(x,y) = matrix(x+vals(pos_selector,1), y+vals(pos_selector,2));      
                elseif strcmpi(sample_mode, 'average')
                    sum_near = 0;
                    for k = 1:length(vals)
                        sum_near = sum_near + matrix(x+vals(k,1), y+vals(k,2));
                    end
                    matrix(x,y) = sum_near./length(vals); % add for all matrices step here
                else
                    error('mode not specified correctly. Either average or random.')
                end
            end
        end
    end
end
