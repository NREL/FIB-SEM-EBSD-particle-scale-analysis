function angles_to_r = function_hist_rs(grain_props, roffset)
%function_hist_rs calculates the actual distance from the particle center
%to each grain of interest. Each grain of interest is assumed to be above
%plane of center. Particles are assumed to be spherical.
%   angles_to_r = function_hist_rs(grain_props, roffset, ptc_cntrd,
%   pixel_to_um_fctr) calculates the distance from a given cross-sectional
%       image to the center of a particle, and includes that vector when
%       calculating the orientation of any grain relative to the center of
%       that particle.
%   
%   Inputs
%       grain_props - grain properties
%       sphere_radius - estimated or real radius of the NMC particle
%           sphere.
% 
%   Outputs
%       angles_to_r - angles between radial grain direction and the
%           direction of c-axis of individual grains
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL        
    
    for n = 1:length(grain_props.grain_labels)    
        grn_cntrd = [grain_props.grain_centroids(n,:), 0];
        grn_frqs = grain_props.orientation_frequencies{n};
        th_temp = grn_frqs(1,3); phi_temp = grn_frqs(1,4); % only considered most common direction -> no grain pairs!!
        [grn_zvec(1), grn_zvec(2), grn_zvec(3)] = sph2cart(th_temp, phi_temp, 1);
        
        rgrain = ([grain_props.ptc_centroid, 0]- grn_cntrd).*grain_props.um_per_pix; % um
        ractual = rgrain + [0 0 roffset];
        ractual = ractual./norm(ractual);
        
        temp_angl = vec_angl(grn_zvec, ractual);
        
        angles_to_r(n) = temp_angl;
    end
end