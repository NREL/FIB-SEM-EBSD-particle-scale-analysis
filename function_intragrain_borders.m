function grain_props = function_intragrain_borders(grain_props, ignore_CI)
%function_intragrain_borders returns matrix of all boundaries within each
%grain
%   grain_props = function_intragrain_borders(grain_props)
%   
%   Inputs
%       grain_props - grain properties
%       ignore_CI - ignores CI if desired
% 
%   Outputs
%       grain_props - updated grain_properties
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

BACKGROUND = 0;

    if nargin < 2
        ignore_CI = true;
    end

    BW = grain_props.BW_intragrain;
    if ~ignore_CI % want to ignore if splits up grains
        BW(~grain_props.CI) = 0;
    end
    labels = unique(BW);
    labels(labels == BACKGROUND) = [];
    
    expected_labels = 1:max(labels);
    
%     particle_idxs = 1:length(labels);    
%     for n = 1:length(non_grain_idxs)
%         particle_idxs(particle_idxs == non_grain_idxs(n)) = [];
%     end
    
    all_boundaries = {};

    border_composite = zeros(size(BW));
    for n = 1:length(expected_labels) % per label, find grain, find boundaries of said grain, document all
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
%     all_boundaries(1) = []; % label 0, or index 1, is never a particle, and is not reported as one by regionprops
    
    
    grain_props.intragrain_boundaries = all_boundaries;
end