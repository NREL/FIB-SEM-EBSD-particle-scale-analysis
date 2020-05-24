function [fig_hist, fig_sections, result] = function_binned_dmap(grain_props, radial_bins, parameter, background_img)
%function plots radial map on specified image and reports distribution of
%values between radial groups
%   [fig_size_dist_plots, dmap_rad_bounds_fig] =
%   function_binned_dmap(edge_dmap, grain_props, radial_bins,
%   pixel_to_um_fctr) returns 2 figures: (1) a colorized map 
%   
%   Inputs 
%       grain_props -grain properties, should have ptc_edge_map
%       radial_bins - number of subdivisions between particle center/edge
%       parameter - must be 'perimeter', 'eccentricity', or 'area', which
%           are plotted with radial bins
% 
%   Outputs
%       fig_hist - figure handle to probabiliyt distribution
%           function which uses Function_probability_density written by
%           Francois Usseglio-Viretta
%       fig_sections - figure handle to radial map
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL
    
    if nargin < 4 
        background_img = grain_props.xyz_cleaned;
    end

    edge_dmap = grain_props.ptc_edge_map;
    pix2um = grain_props.um_per_pix;
    gbs = grain_props.grain_boundaries;
    
    % radial distribution plot
    fig_hist = figure; fig_hist.Color = 'white'; 
    fig_hist.Units = 'inches'; fig_hist.Position(3) = 2.5;
    fig_hist.Position(4) = 2.5;
    
    fig_sections = figure; fig_sections.Color = 'white';
    fig_sections.Units = 'inches'; 
    
    imshow(function_apply_seg_map_to_img(background_img, grain_props.BW))
    for n = 1:length(gbs)
        hold on;
        plot(gbs{n}{1}(:,2), gbs{n}{1}(:,1), 'white', 'LineWidth', 1); 
    end
    
    hold on
    tol = 2;

    sorted_distances = sort(grain_props.grain_dist);
    radial_bounds = linspace(0, sorted_distances(end), radial_bins+1);
    
    if strcmpi(parameter, 'area')
        property_of_interest = grain_props.grain_areas.*(pix2um^2);
        xlab = 'Grain area (\mum^2)'; 
    elseif strcmpi(parameter, 'perimeter')
        property_of_interest = grain_props.grain_perimeter*pix2um;
        xlab = 'Grain perimeter (\mum)'; 
    elseif strcmpi(parameter, 'eccentricity')
        property_of_interest = grain_props.grain_eccentricities;
        xlab = 'Eccentricity'; 
    elseif strcmpi(parameter, 'circularity')
        property_of_interest = grain_props.grain_circularities;
        xlab = 'Circularity';
    elseif strcmpi(parameter, 'poa') % perimeter over area
        property_of_interest = (grain_props.grain_perimeter*pix2um)./(grain_props.grain_areas.*(pix2um^2));
        xlab = 'Perimeter/area (\mum^{-1})';
    end
    

    for n = 1:length(radial_bounds)-1
        lgd_string{n} = [num2str(radial_bounds(n)*pix2um, '%.1f'), ' - ' num2str(radial_bounds(n+1)*pix2um, '%.1f'), ' \mum'];
        d_rng = [radial_bounds(n), radial_bounds(n+1)]
        count = 1; collect_prop = [];
        for m = 1:length(grain_props.grain_centroids) % input (grain_props)
            curr_d = grain_props.grain_dist(m);
            if curr_d > d_rng(1) && curr_d <= d_rng(2)
                collect_prop(count) = property_of_interest(m);
                count = count + 1;
            end
        end
        figure(fig_hist); % OUTPUT
        result = function_prob_density_function_wrapper(collect_prop);
        
        if size(result.smoothed_probability_density_fct, 1) ~= 0
            result.smoothed_probability_density_fct = cat(1, [0,0], result.smoothed_probability_density_fct);
            plot(result.smoothed_probability_density_fct(:,1), ...
                result.smoothed_probability_density_fct(:,2), ...
                'LineWidth', 1.5); hold on;
        end
        
        figure(fig_sections); % OUTPUT
        count2 = 1; xss = []; yss = [];
        for k = 1:size(edge_dmap, 1)
            for m = 1:size(edge_dmap, 2)
                if n ~= length(radial_bounds)-1 && (abs(edge_dmap(k,m) - d_rng(1)) < tol || abs(edge_dmap(k,m) - d_rng(2)) < tol)
                    if edge_dmap(k,m) ~= 0
                        xss(count2) = k; yss(count2) = m; 
                        count2 = count2 + 1;
                    end
                end                
            end
        end
        scatter(yss, xss, 0.5, 'k.'); hold on;
    end
    
    fig_sections.Position(3) = 2.5; fig_sections.Position(4) = 2.5;
    
    figure(fig_hist);
    xlabel(xlab); ylabel('Normalized frequency')
    ax_freq_dist = gca; ax_freq_dist.FontSize = 10;
    lgd_freq_dist = legend(lgd_string); lgd_freq_dist.Box = 'off';
end