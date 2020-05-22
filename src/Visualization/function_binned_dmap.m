function [fig_size_dist_plots, dmap_rad_bounds_fig, results_d2] = function_binned_dmap(grain_props, radial_bins, parameter, background_img)
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
%       fig_size_dist_plots - figure handle to probabiliyt distribution
%           function which uses Function_probability_density written by
%           Francois Usseglio-Viretta
%       dmap_rad_bounds_fig - figure handle to radial map
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL
    
    if nargin < 4 
        background_img = grain_props.xyz_cleaned;
    end

    edge_dmap = grain_props.ptc_edge_map;
    pixel_to_um_fctr = grain_props.um_per_pix;
    
    % radial distribution plot
    fig_size_dist_plots = figure; fig_size_dist_plots.Color = 'white'; 
    fig_size_dist_plots.Units = 'inches'; fig_size_dist_plots.Position(3) = 2.5;
    fig_size_dist_plots.Position(4) = 2.5;
    
    dmap_rad_bounds_fig = figure; dmap_rad_bounds_fig.Color = 'white';
    dmap_rad_bounds_fig.Units = 'inches'; 
    
    imshow(function_apply_seg_map_to_img(background_img, grain_props.BW))
    for n = 1:length(grain_props.grain_boundaries)
        hold on;
        plot(grain_props.grain_boundaries{n}{1}(:,2), grain_props.grain_boundaries{n}{1}(:,1), 'white', 'LineWidth', 1); 
    end
    
    hold on
    tol = 2;

    sorted_distances = sort(grain_props.grain_dist);
    radial_bounds = linspace(0, sorted_distances(end), radial_bins+1);
    
    if strcmpi(parameter, 'area')
        property_of_interest = grain_props.grain_areas.*(pixel_to_um_fctr^2);
        xlab = 'Grain size (\mum^2)'; 
    elseif strcmpi(parameter, 'perimeter')
        property_of_interest = grain_props.grain_perimeter*pixel_to_um_fctr;
        xlab = 'Grain perimeter (\mum)'; 
    elseif strcmpi(parameter, 'eccentricity')
        property_of_interest = grain_props.grain_eccentricities;
        xlab = 'Grain eccentricity'; 
    elseif strcmpi(parameter, 'circularity')
        property_of_interest = grain_props.grain_circularities;
        xlab = 'Grain circularity';
    elseif strcmpi(parameter, 'poa') % perimeter over area
        property_of_interest = (grain_props.grain_perimeter*pixel_to_um_fctr)./(grain_props.grain_areas.*(pixel_to_um_fctr^2));
        xlab = 'perimeter/area (\mum^{-1})';
    end
    

    for n = 1:length(radial_bounds)-1
        lgd_string{n} = [num2str(radial_bounds(n)*pixel_to_um_fctr, '%.1f'), ' - ' num2str(radial_bounds(n+1)*pixel_to_um_fctr, '%.1f'), ' \mum'];
        d_rng = [radial_bounds(n), radial_bounds(n+1)]
        count = 1; collected_areas = [];
        for m = 1:length(grain_props.grain_centroids) % input (grain_props)
            curr_d = grain_props.grain_dist(m);
            if curr_d > d_rng(1) && curr_d <= d_rng(2)
                collected_areas(count) = property_of_interest(m);
                count = count + 1;
            end
        end
        figure(fig_size_dist_plots); % OUTPUT
        results_d2 = function_prob_density_function_wrapper(collected_areas);
        
        results_d2.x50
        
        if size(results_d2.smoothed_probability_density_fct, 1) ~= 0
            results_d2.smoothed_probability_density_fct = cat(1, [0,0], results_d2.smoothed_probability_density_fct);
            plot(results_d2.smoothed_probability_density_fct(:,1), results_d2.smoothed_probability_density_fct(:,2), 'LineWidth', 1.5); hold on; % INPUT (pixel_to_um_fctr)
        end
        
        figure(dmap_rad_bounds_fig); % OUTPUT
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
    
    dmap_rad_bounds_fig.Position(3) = 2.5; dmap_rad_bounds_fig.Position(4) = 2.5;
    
    figure(fig_size_dist_plots);
    xlabel(xlab); ylabel('Normalized frequency')
    ax_freq_dist = gca; ax_freq_dist.FontSize = 10;
    lgd_freq_dist = legend(lgd_string); lgd_freq_dist.Box = 'off';
end