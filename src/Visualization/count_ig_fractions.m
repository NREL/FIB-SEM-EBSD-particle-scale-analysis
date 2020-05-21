function [g_sz, g_f, g_ft, g_szt] = count_ig_fractions(grain_props)
%count_ig_fractions counts the fraction of a grain which is intragrain by
%area
%
%   [g_sz, g_f, g_ft, g_szt] = count_ig_fractions(grain_props)
%   
%   Inputs
%       grain_props - grain_properties
% 
%   Outputs
%       g_sz
%       g_f
%       g_ft
%       g_szt
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    g_sz = [];      % size of grain
    g_f = [];       % fraction of grain intragrain
    g_ft = [];      % sum of fractions in grain
    g_szt = [];     % size of grain

    gls = grain_props.grain_labels; % grain labels
    
    for n = 1:length(gls)                      % per each grain
        new_mat = grain_props.BW_intragrain;                        % holds intragrain labels
        new_mat(grain_props.BW ~= gls(n)) = 0; % holds intragrain data in single grain
        rem = unique(new_mat); rem(rem == 0) = [];                  % intragrain_labels in grain 
        grn_size_n = length(find(new_mat > 0));                     % number of pixels in grain
        curr_grn_size = [];
        curr_grn_frac = [];
        count = 0;
        for m = 1:length(rem)
            count = count + 1;
            curr_grn_size(count) = grn_size_n*(grain_props.um_per_pix^2);
            [r,c] = find(grain_props.BW_intragrain == rem(m)); % grain size
            curr_grn_frac(count) = length(r)*(grain_props.um_per_pix^2)/curr_grn_size(count);
            if curr_grn_frac(count) > 1; error('bigger than grain?'); end
        end
        srs = sortrows([curr_grn_size(:), curr_grn_frac(:)], 2, 'descend');
        srs(1,:) = []; % remove largest component of grain
        curr_grn_size = srs(:,1);
        curr_grn_frac = srs(:,2);

        g_sz = cat(1, g_sz, curr_grn_size(:));
        g_f = cat(1, g_f, curr_grn_frac(:));

        % sometimes the grain has no intragrains
        if isempty(curr_grn_frac)
            g_ft(n) = NaN;
        else
            g_ft(n) = sum(curr_grn_frac); % total amount of grain that is not most frequent size
        end
        g_szt(n) = grn_size_n*(grain_props.um_per_pix^2);
    end
    
end