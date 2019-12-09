function [new_BW, BW_seq] = function_remove_web(BW, struct_el)
%function_remove_web dilates grains (integers>1) into webbing 
%   new_Bw = function_remove_web(BW) dilates grains into webbing one-by-one
%       using strel('disk', 3)
%   new_Bw = function_remove_web(BW, struct_el) can specify structuring
%       element as desired for dilation operations
%   
%   Inputs
%       BW - segmented matrix where 0 = background, 1 = webbing, and 2 =
%           grains
%       struct_el (optional) - structuring element used for dilation operations 
% 
%   Outputs
%       new_BW - grains without any webbing
%       BW_seq - cell array of dilation sequence
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

WEB = 1; 
BCKGND = 0;
    
    lbls = unique(BW);
    old_BW = zeros(size(BW));
    new_BW = BW; % labeled unsegmented image
    
    if nargin < 2
        dilate_element = strel('disk', 3, 0); % change for different behavior, square of size 2 only dilates on corners
    else
        dilate_element = struct_el;
    end
    
    static_locations = ismember(BW, BCKGND);
    
    
    lbls(lbls == BCKGND) = []; % exclude background from grain idxs
    lbls(lbls == WEB) = []; % erode regions
    
    count = 0;
    figss = {};
    
    while ~isequal(new_BW, old_BW)
        
        count = count + 1;
%         figss{count} = figure;
        disp(['Dilation Iteration: ' num2str(count)])
        
        old_BW = new_BW;        
        
        for n = 1:length(lbls) % per particle
            particle_only = zeros(size(old_BW)); % zero background to distinguish particle from not
            
            [r, c] = find(old_BW == lbls(n)); % grab particle idxs, lew labels each iteration

            mask_idx = sub2ind(size(old_BW), r, c); % all indicies of current particle
            particle_only(mask_idx) = old_BW(mask_idx); % overlay particle features on zero background
            
            dilated_particle = imdilate(particle_only, dilate_element); % dilate the particle
            
            num_points = numel(old_BW); % for every single point in segmentation map, create bounding box to reduce comparisons dramatically
            for m = 1:num_points % big memory and time cost...numel(BW) * numel(labels) * number of iterations...easily > 1 billion comparisons
                if ~static_locations(m)&& dilated_particle(m) ~= BCKGND && old_BW(m) == WEB % update BW where dilated particle extends into boundary territory only, 0 is anything not considered particle (static_regions_idx)
                    new_BW(m) = dilated_particle(m);
                    
                end
            end
        end
        BW_seq{count} = label2rgb(new_BW);
        imshow(label2rgb(new_BW)) % show progressing secondary particle dilations        
    end
    new_BW(new_BW == 1) = 0; % cleaning for leftover segmentation boundaries
end