function grain_props = calc_grain_morphology(grain_props)
    % implement CI map
BACKGROUND = 0;

    BW = grain_props.BW;    
    grain_boundaries = grain_props.grain_boundaries; % may not be necessary
    CI_map = grain_props.CI;
      
    BW(~CI_map) = 0;% make into background
    labels = unique(BW);
    labels(labels == BACKGROUND) = [];
    
    % retrieve properties
    sec_particle_properties = regionprops(BW, 'Area', 'Centroid', 'Circularity', 'Perimeter', 'Eccentricity');
    grain_centroids = round(cat(1, sec_particle_properties.Centroid));
    grain_areas = cat(1, sec_particle_properties.Area);
    grain_circularities = cat(1, sec_particle_properties.Circularity);
    grain_perimeters = cat(1, sec_particle_properties.Perimeter);
    grain_eccentricities = cat(1, sec_particle_properties.Eccentricity);
    
    expected_labels = 1:max(labels);
    
    bool_keep = ismember(expected_labels, labels);

    grain_props.grain_labels = expected_labels(bool_keep); % remove all values where NaN exists
    grain_props.grain_centroids = grain_centroids(bool_keep, :); 
    grain_props.grain_areas = grain_areas(bool_keep); 
    grain_props.grain_circularities = grain_circularities(bool_keep);
    grain_props.grain_boundaries = grain_boundaries(bool_keep);
    grain_props.grain_perimeter = grain_perimeters(bool_keep);
    grain_props.grain_eccentricities = grain_eccentricities(bool_keep);
end