function grain_props = function_intragrain_properties(grain_props)
%function_intragrain_properties uses region props to get information about
%each intragrain
%   grain_props = function_intragrain_properties(grain_props)
%   
%   Inputs
%       grain_props - grain properties
% 
%   Outputs
%       grain_props - grain properties updated with centroid, area,
%       	circularity, eccentricity, and perimeter
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL
BACKGROUND = 0;

    BW = grain_props.BW_intragrain;
    CI_map = grain_props.CI;
    
    BW(~CI_map) = 0;% make into background
    labels = unique(BW);
    labels(labels == BACKGROUND) = [];
    
    % retrieve properties
    intragrain_properties = regionprops(BW, 'Area', 'Centroid', 'Circularity', 'Perimeter', 'Eccentricity');
    grain_centroids = round(cat(1, intragrain_properties.Centroid));
    grain_areas = cat(1, intragrain_properties.Area);
    grain_circularities = cat(1, intragrain_properties.Circularity);
    grain_perimeters = cat(1, intragrain_properties.Perimeter);
    grain_eccentricities = cat(1, intragrain_properties.Eccentricity);
    
    expected_labels = 1:max(labels);
    bool_keep = ismember(expected_labels, labels);
    
    %% need to include bool keep!    
    grain_props.intragrain_labels = expected_labels(bool_keep);
    grain_props.intragrain_centroids = grain_centroids(bool_keep, :); 
    grain_props.intragrain_areas = grain_areas(bool_keep); 
    grain_props.intragrain_circularities = grain_circularities(bool_keep);
    grain_props.intragrain_perimeter = grain_perimeters(bool_keep);
    grain_props.intragrain_eccentricities = grain_eccentricities(bool_keep);

end