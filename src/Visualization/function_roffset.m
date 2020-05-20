function roffset = function_roffset(grain_props, sphere_radius)

rslice = sqrt(grain_props.ptc_area*(grain_props.um_per_pix^2)/pi); % um ^2
if rslice < sphere_radius
    roffset = sqrt(sphere_radius^2 - rslice^2); % um
else
    roffset = 0;
end
    
end