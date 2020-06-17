function BW = bwremovelabels(BW, rm_lab)
%bwremovelabels removes and/or relabels segmented matrix 
%   BW = bwremovelabels(BW, rm_lab) removes all regions in BW that
%       are listed in rm_lab and relabels regions to be consecutive
%   
%   Inputs
%       BW - segemented matrix
%       rm_lab - list of labels corresponding to regions to remove from BW. 
% 
%   Outputs
%       BW - segmented matrix with removed regions and consecutive labels
%       (e.g. unique(BW) will have no integer gaps)
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    BW(ismember(BW, rm_lab)) = 0; % make removed = background
    new_labels = unique(BW); % all new labels are not connsecutive, grab
    new_labels(new_labels == 0) = []; % 0 is background, do not rename
    for n = 1:length(new_labels) % for each sequential but non-consecutive label
        BW(BW == new_labels(n)) = n; % make label index, where 1 is the first grain and 'end' is the last grain
    end
end