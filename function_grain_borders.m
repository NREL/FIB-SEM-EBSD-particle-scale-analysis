function [grain_props, border_composite] = function_grain_borders(grain_props, ignore_CI)
%function_grain_borders implementation of bwboudnaries to save boudnaries
%for every grain in image
%   [grain_props, border_composite] = function_grain_borders(grain_props)
%   
%   Inputs
%       grain_props - matrix...
%       ignore_CI - ignores CI if desired
% 
%   Outputs
%       grain_props - updated grain_props with array of boundaries
%       border_composite - binary image of border locations
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

BACKGROUND = 0;

    if nargin < 2
        ignore_CI = true;
    end  

    BW = grain_props.BW;
    if ~ignore_CI % want to ignore if splits up grains
        BW(~grain_props.CI) = 0;
    end
    labels = unique(grain_props.BW);
    labels(labels == BACKGROUND) = [];
%     particle_idxs = 1:length(labels);    
    
    expected_labels = 1:max(labels);
    
    all_boundaries = {};

    border_composite = zeros(size(BW));
    for n = 1:length(expected_labels)% length(particle_idxs) % per label, find grain, find boundaries of said grain, document all
        if ismember(expected_labels(n), labels) % expected label exists
            curr_map = (BW == expected_labels(n));
            all_boundaries{n} = bwboundaries(curr_map, 'noholes');
            c_cell = all_boundaries{n};
            if ~isempty(c_cell)
                idxxs = sub2ind(size(border_composite), c_cell{1}(:,1), c_cell{1}(:,2));
                border_composite(idxxs) = 1;
            end
        else
            all_boundaries{n} = NaN;
        end
    end    
    
    grain_props.grain_boundaries = all_boundaries;
end