function [angles_b, angles_g] = count_gig_boundaries(grain_props, bd_map)
% count grain and intragrain boundaries, make sure is in bd_map

    angles_in_boundary = 0;
    angles_in_grain = 0;
    angles_b = nan(length(grain_props.intragrain_border_angles), 1);
    angles_g = nan(length(grain_props.intragrain_border_angles), 1);

    for n = 1:length(grain_props.intragrain_border_angles)
        x1 = round(grain_props.intragrain_border_angles(n,1));
        y1 = round(grain_props.intragrain_border_angles(n,3));
        angle = grain_props.intragrain_border_angles(n,5);

        if bd_map(x1, y1)
            angles_in_boundary = angles_in_boundary + 1;
            angles_b(angles_in_boundary) = angle;
        else
            angles_in_grain = angles_in_grain + 1;
            angles_g(angles_in_grain) = angle;
        end
    end
    angles_b(isnan(angles_b)) = [];
    angles_g(isnan(angles_g)) = [];

end