function [grain_props, clean_time] = function_cleaning(grain_props, area_tol, fill_region)
%function_cleaning iteratively cleans 'speckling' of the data. Intragrains
% below a specific threshold in size (input as pixels^2, or the # of
% pixels) are removed by comparing the neighbors and replacing with most
% common orientation
%
%   Inputs
%       grain_props - contains grain information. Required fields are: 
%           'BW_intragrain', 'tp_mat_cleaned', 'orientation_frequencies',
%           'grain_labels', 'BW', ''
%       area_tol - size tolerance (in pixels) of feature to remove
%       fill_region - if true fills each grain with most frequent
%           orientation 
% 
%   Outputs
%       grain_props - fields added/updated are:
%           orientation_frequencies - intragrain label, #frequency, theta, phi
%           BW_intragrain - labeled intragrains
%           tp_mat_cleaned - cleaned theta, phi map
%           xyz_cleaned - cleaned x,y,z map
%       clean_time - times to clean each grain
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

% Need to apply a step to remove 0-frequency values and reorder
% intragrain_BW such that intragrain_labels doesn't skip any entries

if nargin < 3
    fill_region = false;
end

BW_ig = grain_props.BW_intragrain;
th_phi_mat_cleaned = grain_props.tp_mat_cleaned;

if fill_region
    disp('fill_region according to most frequent component')
    for grn = 1:length(grain_props.grain_labels) % per grain
        grn_freqs = grain_props.orientation_frequencies{grn};
        
        % ordered, first entry is most frequent orientation
        most_frequent_vals = grn_freqs(1,:); 
        
        % find indices of grain locations and linearize idexes to replace
        % with most frequent orientations
        [r, c] = find(grain_props.BW == grn);        
        lin_idx_1 = sub2ind(size(th_phi_mat_cleaned), r, c, ones(length(r),1));
        lin_idx_2 = sub2ind(size(th_phi_mat_cleaned), r, c, 2*ones(length(r),1));
        
        % update all orientations within grain with most frequent
        % orientation
        th_phi_mat_cleaned(lin_idx_1) = most_frequent_vals(3); %theta
        th_phi_mat_cleaned(lin_idx_2) = most_frequent_vals(4); % phi
    end    
    
    % because each grain only contains one orientation, the intragrain map
    % is the the same as the labeled map - may not work as intended if
    % using BW_intragrain
    BW_ig = grain_props.BW;
 
else    
    for grn = 1:length(grain_props.grain_labels) % per grain
        tic % timing
        
        grn_lbl = grain_props.grain_labels(grn); % label for grain
        ingrain_seg_mat_old = 0; ingrain_seg_mat = 1; % inital condition to ensure execution of while loop
        while ingrain_seg_mat_old ~= ingrain_seg_mat % surprised this syntax works: compares each cleaning step 
            grn_freqs = grain_props.orientation_frequencies{grn};
            
            ingrain_seg_mat = grain_props.BW_intragrain; % Created to compare specific grains
            ingrain_seg_mat(grain_props.BW ~= grn_lbl) = 0; % inside specific grain
            ingrain_seg_mat_old = ingrain_seg_mat; % store for comparison after cleaning
            
            sort_grp_freqs = grn_freqs(:,1:2); % already sorted by descending order of frequency
            
            for n = 2:size(sort_grp_freqs,1) % for each intragrain
                temp_ingrain_seg_mat = ingrain_seg_mat; % holds only intragrain labels
                temp_ingrain_seg_mat(temp_ingrain_seg_mat ~= sort_grp_freqs(n,1)) = 0; % anything but the specific intragrain = 0
                         
                sz_ig = nnz(temp_ingrain_seg_mat); % nnz = nonzero entries matrix, effectively size of intragrain
                
                if sz_ig <= area_tol % only consider intragrains below specific size
                    temp_ingrain_seg_mat(temp_ingrain_seg_mat == sort_grp_freqs(n,1)) = 1; % only one intragrain considered, == 1 ensures bwboundaries works as expected

                    bds_cell = bwboundaries(temp_ingrain_seg_mat); % get boundaries
                    bds = bds_cell{1}; % list of pixel postion of boundary for intragrain of interest

                    % search boundaries for most common value in original single-grain segmented matrix
                    counts = 1; % # of bordering pixels that are different angle
                    type_on_border = [];

                    % collect all orientation directions at borders
                    for k = 1:length(bds) % per boundary value
                        l = [bds(k,1) - 1, bds(k,2)]; % left
                        r = [bds(k,1) + 1, bds(k,2)]; % right
                        u = [bds(k,1), bds(k,2) + 1]; % up
                        d = [bds(k,1), bds(k,2) - 1]; % down               
                        lrud = [l;r;u;d];

                        for j = 1:length(lrud)
                            if (lrud(j,1) > 0 &&...                                     % in bounds left side
                                    lrud(j,1) < size(ingrain_seg_mat, 1) &&...          % in bounds right side
                                    lrud(j,2) > 0 &&...                                 % in bounds bottom
                                    lrud(j,2) < size(ingrain_seg_mat, 2) &&...          % in bounds top
                                    (ingrain_seg_mat(lrud(j,1), lrud(j,2))~= 0) &&...   % inside grain of interest
                                    temp_ingrain_seg_mat(lrud(j,1), lrud(j,2))~= 1)     % not the same orientation as self
                                
                                % list of labels for intragrains that
                                % border intragrain of interest
                                type_on_border(counts) = ingrain_seg_mat(lrud(j,1), lrud(j,2)); 
                                counts = counts + 1;
                            end
                        end                    
                    end
                    
                    % with border type counts, use original segmentation area to replace all values with most common type
                    if ~isempty(type_on_border)
                        most_common_neighbor = mode(type_on_border); % intragrain label for most common neightor vector
                        row_mcn = find(grn_freqs(:,1) == most_common_neighbor); % row in grn_freqs contains theta, phi, and intragrain label info
                        
                        [r_cluster, c_cluster] = find(temp_ingrain_seg_mat == 1); % find pixels in cluster
                        for k = 1:length(r_cluster)
                            
                            % replace with label
                            BW_ig(r_cluster(k), c_cluster(k)) = grn_freqs(row_mcn, 1);
                            
                            % update the matrix which holds the theta/phi values
                            % replaces intragrain with most frequent
                            % orientation of neighbors
                            th_phi_mat_cleaned(r_cluster(k), c_cluster(k), 1) = grn_freqs(row_mcn, 3);
                            th_phi_mat_cleaned(r_cluster(k), c_cluster(k), 2) = grn_freqs(row_mcn, 4);
                            
                            % update labeling matrix (which exists only for
                            % duration of cleaning intragrains)
                            ingrain_seg_mat(r_cluster(k), c_cluster(k)) = most_common_neighbor;
                        end
                        
                        % update frequencies - if intragrain removed
                        % grn_freqs -> 0
                        grn_freqs(row_mcn,2) = grn_freqs(row_mcn,2) + k;
                        grn_freqs(n,2) = 0;                        
                    end
                end
            end
            grain_props.orientation_frequencies{grn} = grn_freqs; % update frequencies
        end
        disp(['Cleaning grain: ', num2str(grn)]);
        clean_time(grn) = toc; disp([num2str(clean_time(grn)), ' s']);
    end
end

% update grain_props
grain_props.xyz_cleaned = function_sphmat2xyzmat(th_phi_mat_cleaned);
grain_props.tp_mat_cleaned = th_phi_mat_cleaned;
grain_props.BW_intragrain = BW_ig;
end