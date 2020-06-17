function [grain_props, grp_time] = caxis_grouping(grain_props, theta_tol)
%caxis_grouping groups vectors which are similar in angle (within 1.5
% degrees in both theta/phi directions) and then creates a segmentatation
% that groups the regions within each grain that are oriented differently
%   
%   Inputs
%       grain_props - matrix containing grain properties. Fields which must
%           be filled are 'BW', 'tp_mat', 'xyz_pos', 'grain_labels'
%       theta_tol - tolerance in degrees required to group pixels of
%           specific orientation. EBSD detector accuracy ~ 3-4 degrees.
%           default ~ 2 degrees for tolerance in EBSD.
% 
%   Outputs
%       grain_props - the fields added to this struct are:
%           orientation_frequencies - 
%           xyz_cleaned - 
%           tp_mat_cleaned - 
%           BW_intragrain - 
%       grp_time - time required for each set of vectors to be grouped
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    rad_tol = theta_tol/360*2*pi; % tolerance to grouping in radians
        
    BW = grain_props.BW;
    th_phi_mat = grain_props.tp_mat;
    th_phi_mat_negs = xyz2sph_mat(-grain_props.xyz_pos);
    
    % angles between z-vectors
    th_phi_mat_cleaned = th_phi_mat; % theta/phi map 
    grain_pair_counter = 0; % new value for every single intragrain
    BW_ig = zeros(size(BW)); % end result for all intragrain mappings
    
    for grn = 1:length(grain_props.grain_labels) % per grain
        single_grain_seg_mat = zeros(size(BW)); % for segmenting small items in each grain 

        lbls = grain_props.grain_labels(grn);    
        [r,c] = find(BW == lbls); % list of pixels relevant to grain

        idxu = 1:length(r); % initially, all indexes to r,c pairs, unused indexes in grouping algorithm
        th_lin_idxs = sub2ind(size(th_phi_mat),r,c,ones(length(r),1)); % linear indexes for theta values (azimuth) - correspond to r,c
        phi_lin_idxs = sub2ind(size(th_phi_mat),r,c,2*ones(length(r),1)); % linear indexes for phi values (elevation) - correspond to r,c
        
        ths_lin = th_phi_mat(th_lin_idxs); % linearized thetas for all r,c
        phis_lin = th_phi_mat(phi_lin_idxs); % linearized phis for all r,c
        ths_lin_negs = th_phi_mat_negs(th_lin_idxs); % same as above but holds negatives for comparison at edge cases
        phis_lin_negs = th_phi_mat_negs(phi_lin_idxs);

        counter = 0; % count groups
        grp = []; % use counter to identify group
        freq = []; % number of pixels in each group
        c_theta_at_counter = [];
        c_phi_at_counter = [];
        
        tic
        while ~isempty(idxu) % idxu contains indexes to all positions in grain
            counter = counter + 1;
            
            % ungrouped values form relevant part of matrix (vector directions that haven't been grouped/accounted for)
            ths_lin_resize = ths_lin(idxu); phis_mat_resize = phis_lin(idxu);
            ths_lin_negs_resize = ths_lin_negs(idxu); phis_lin_negs_resize = phis_lin_negs(idxu);

            idx1 = idxu(1); % select first unaccounted value - idx1 points to item in r,c,
            c_theta = ths_lin(idx1);
            c_phi = phis_lin(idx1);

            idxs_in_tol_norm = ismembertol(ths_lin_resize, c_theta, rad_tol) & ismembertol(phis_mat_resize, c_phi, rad_tol); % group theta phi pairs that fit both phi and theta tolerance
            idxs_in_tol_opp_dir = ismembertol(ths_lin_negs_resize, c_theta, rad_tol) & ismembertol(phis_lin_negs_resize, c_phi, rad_tol); % group edge cases (180 deg from each other)
            all_idxs_in_tol = idxs_in_tol_norm | idxs_in_tol_opp_dir; % all vectors in tolerance

            idxc = idxu(all_idxs_in_tol); % points to all indexes that have same tolerance

            for n = 1:length(idxc)% for groupable elements - group elements
                th_phi_mat_cleaned(r(idxc(n)), c(idxc(n)), 1) = c_theta;
                th_phi_mat_cleaned(r(idxc(n)), c(idxc(n)), 2) = c_phi;
                single_grain_seg_mat(r(idxc(n)), c(idxc(n))) = counter;
            end

            grp(counter) = counter; % label for next segmentation - each counter value is a grouping of orientations within tolerance
            freq(counter) = length(idxc);
            c_theta_at_counter(counter) = c_theta;
            c_phi_at_counter(counter) = c_phi;

            idxu = (idxu(~all_idxs_in_tol)); % these values have been grouped and do not need to be accessed again, idxu is shrunk
        end
        
        
        % After grouping, every single cluster within a grain needs to be
        % re-identified using segmentation. The labels are saved in BW
        
        new_group = [];
        new_frequency = [];
        new_theta = [];
        new_phi = [];
        
        for n = 1:length(grp) % n is the same as counter
            current_theta = c_theta_at_counter(n);
            current_phi = c_phi_at_counter(n);
            if freq(n) > 0
                % segment
                temp_ingrain_seg_mat = single_grain_seg_mat;
                temp_ingrain_seg_mat(temp_ingrain_seg_mat ~= n) = 0;
                temp_ingrain_seg_mat(temp_ingrain_seg_mat == n) = 1;
                bwlab_grain = bwlabel(temp_ingrain_seg_mat, 4); % segement specific frequency group
                
                intragrain_lbls = unique(bwlab_grain);
                intragrain_lbls(1) = []; % remove 0
                
                for m = 1:length(intragrain_lbls)
                    grain_pair_counter = grain_pair_counter + 1;
                    [r,c] = find(bwlab_grain == intragrain_lbls(m));
                    subindsss = sub2ind(size(bwlab_grain), r, c);
                    
                    BW_ig(subindsss) = grain_pair_counter;
                    new_group(grain_pair_counter) = grain_pair_counter;
                    new_frequency(grain_pair_counter) = length(r);
                    new_theta(grain_pair_counter) = current_theta;
                    new_phi(grain_pair_counter) = current_phi;
                end
            end
        end
                
        % count frequency and groups again
        grain_props.orientation_frequencies{grn} = sortrows([new_group(:), new_frequency(:), new_theta(:), new_phi(:)], 2, 'descend');    
        grain_props.orientation_frequencies{grn}(grain_props.orientation_frequencies{grn}(:,2) == 0, :) = [];
        
        disp(['grouping of grain number: ', num2str(grn)]);
        grp_time(grn) = toc; disp([num2str(grp_time(grn)), ' s'])        
    end
        
%     xyz_cleaned = sph2xyz_mat(th_phi_mat_cleaned);
    grain_props.xyz_cleaned = sph2xyz_mat(th_phi_mat_cleaned);
    grain_props.tp_mat_cleaned = th_phi_mat_cleaned;
    grain_props.BW_intragrain = BW_ig;  
end