function map = show_r_orientation(grain_props, roff)
% roff - roffset in um

sz_bw = size(grain_props.BW);
map = zeros(sz_bw);

[xs, ys] = meshgrid(1:sz_bw(2), 1:sz_bw(1));

xs = (xs - grain_props.ptc_centroid(1)) * grain_props.um_per_pix;
ys = (ys - grain_props.ptc_centroid(2)) * grain_props.um_per_pix;

for n = 1:(sz_bw(1))
    for m  = 1:sz_bw(2)
        if grain_props.BW(n,m) > 0
            c_dir = squeeze(grain_props.xyz_pos(n,m,:)); % c-axis of current pixel
            r_real = [xs(n,m), ys(n,m), roff]';
            
            a = vec_angl(c_dir, r_real);
            map(n,m) = a;
        end
    end
end

dist_map = sqrt(xs.^2 + ys.^2 + roff^2);
end