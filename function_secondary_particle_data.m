function grain_props = function_secondary_particle_data(grain_props, multiple_primary_particles) % shouldn't need CI map
%function_secondary_particle_data calculates parameters of secondary
%particle (one large segmentation area)
%   [x,y] =  function(a,b) does ....
%   
%   Inputs
%       grain_props - grain properties
% 
%   Outputs
%       grain_props - grain_props is updated with grain_props. -ptc_map,
%           -ptc_centroid, -ptc_area, and -ptc_edge_map
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

BACKGROUND = 0;
    
    BW = grain_props.BW;
    labels = unique(grain_props.BW);
    
%     [r, c] = find(BW == labels(outer_region_idx)); % outer region allows determination of primary particles
    
    
    bckgrd_map = zeros(size(BW));
    bckgrd_map(BW == BACKGROUND) = 1;
    
%     bckgrnd_idxs = sub2ind(size(BW), r, c);
%     bckgrd_map(bckgrnd_idxs) = 1; % background is 1 in this case
    
    primary_particle_map = ~bckgrd_map;
    if multiple_primary_particles == true % resegment background, select only primary particle
        primary_particle_map = bwlabel(primary_particle_map, 4); % segment particle areas
    end
    t = regionprops(primary_particle_map, 'Centroid', 'Area'); % get centroid of image
    for n = 1:length(t) % unpack primary particle area
        struct_n = t(n);
        centroids(n, :) = struct_n.Centroid;
        areas(n) = struct_n.Area;
    end
    
    [area, primary_particle_idx] = max(areas);
    centroid_of_concern = round(centroids(primary_particle_idx, :));
    centroid_only_map = zeros(size(BW));
    centroid_only_map(centroid_of_concern(1), centroid_of_concern(2)) = 1; % single point on map has centroid from primary particle
    
    % in single particle mode, bwdist here
    dist_map_from_centroid = bwdist(centroid_only_map);
    dist_map_from_edge = bwdist(bckgrd_map);
        
    grain_props.ptc_map = primary_particle_map;
    grain_props.ptc_centroid = centroid_of_concern;
    grain_props.ptc_area = area;
    grain_props.ptc_edge_map = dist_map_from_edge;
end