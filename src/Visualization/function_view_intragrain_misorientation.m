function ig_orients = function_view_intragrain_misorientation(grain_props)
%function_view_intragrain_misorientation takes each grain in an image, and
%color codes grains based on their different orientation
%   ig_orients = function_view_intragrain_misorientation(grain_props) uses
%       the grain_props.orientation_frequencies, which has a tally of
%       the directions and the frequency, to get the most commmon direction
%   
%   Inputs
%       grain_props - grain_properties
% 
%   Outputs
%       ig_orients - figure handle
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    xyz_cleaned = grain_props.xyz_cleaned;
    th_phi_mat_cleaned = grain_props.tp_mat_cleaned;
    BW_final = grain_props.BW;

    xyz_angle_discrepancy2 = zeros(size(xyz_cleaned,1), size(xyz_cleaned,2));
    for n = 1:length(grain_props.grain_labels)
        th_most_common = grain_props.orientation_frequencies{n}(1,3);
        phi_most_common = grain_props.orientation_frequencies{n}(1,4);
        [v1(1),v1(2),v1(3)] = sph2cart(th_most_common,phi_most_common,1);
        [r,c] = find(BW_final == grain_props.grain_labels(n));
        for m = 1:length(r) % per item in grain
            cth = th_phi_mat_cleaned(r(m),c(m), 1);
            cphi = th_phi_mat_cleaned(r(m),c(m), 2);
            [v2(1),v2(2),v2(3)] = sph2cart(cth,cphi,1);
            anlg = vec_angl(v1,v2);
%             anlg = acosd(dot(v1,v2)/sqrt(sum(v1.^2))/sqrt(sum(v2.^2)));
%             if anlg > 90; anlg = anlg - 90; end
            xyz_angle_discrepancy2(r(m),c(m))= anlg;
        end
    end

    figure; imshow(1-(xyz_angle_discrepancy2/90)); % normalize to div by 90
    for n = 1:length(grain_props.grain_boundaries)
        hold on; plot(grain_props.grain_boundaries{n}{1}(:,2), grain_props.grain_boundaries{n}{1}(:,1), 'k', 'LineWidth', 1.5)
    end
    colormap([ones(255,1), (1:255)'/255, (1:255)'/255])
    set(gca, 'units', 'normalized', 'position', [0 0 1 1])
    ig_orients = frame2im(getframe(gcf));
    close(gcf);
end