function grain_props = function_grain_distances(grain_props)
%function_grain_distances(grain_props)
%   grain_props = function_grain_distances(grain_props) calculates distance
%       from particle edge to each individual grain
%   
%   Inputs
%       grain_props - particle information
% 
%   Outputs
%       grain_props - added distances to particles (grain_props.grain_dist)
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

grain_centroids = grain_props.grain_centroids;
dmap = grain_props.ptc_edge_map;
    for n = 1:length(grain_props.grain_labels)        
        grain_props.grain_dist(n) = dmap(grain_centroids(n, 2), grain_centroids(n, 1));
    end
end