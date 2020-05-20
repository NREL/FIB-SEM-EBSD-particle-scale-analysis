function map = function_map_rmisorientation(grain_props, roff)
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
            
            a = 2*atan2d(norm( c_dir*norm(r_real) - norm(c_dir)*r_real), norm(c_dir*norm(r_real) + norm(c_dir)*r_real));
            if 90-a <= 0; a = 180-a; end % obtain acute angle            
            
            map(n,m) = a;
        end
    end
end

dist_map = sqrt(xs.^2 + ys.^2 + roff^2);
% figure; s = surf(dist_map); s.EdgeColor = 'none'; view(2)
% figure; imshow(mat2gray(dist_map));
end