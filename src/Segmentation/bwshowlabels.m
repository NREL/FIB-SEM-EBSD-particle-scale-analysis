function bwshowlabels(BW, location)
% bwshowlabels labels numbered matrices
%   fig = bwshowlabels(BW, location) displays a text for each
%   unique integer in a 2D matrix. This does not include
%   
%   Inputs
%       BW - 2D uint8 matrix, can be output of segmentation such as BWlabel
%       location - specifies where to label each item
%           'centroid' - at centroid of object
%           'first' - at first indexed pixel of object (use when location
%               of centroid may be in region outside of object
% 
%   Outputs
%       fig - handle to figure containing labeled integer map
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Inspired by discussions with: Donal P. Finagan, NREL
%   Additional assistance from:  Francois Usseglio-Viretta, NREL
    
    if ~all(floor(BW) == BW, 'all')
        error(['Please ensure all values in BW matrix are integers.' ,... 
            'If applicable, can be performed with round, floor, or ceil.'])
    end
    
    lbls = unique(BW); % all numbers in map
    lbls(lbls == 0) = []; % 0 is considered background
    
    sequence_nums = 1:max(lbls); % regionprops fills in gaps where data doesnt exist, e.g. if matrix has values [1,2,4] in it, regionprops will spit out values for 3 (Area = 0, perimeter = 0, etc...)
    bool_keep = ismember(sequence_nums, lbls); % determine which regionprops values are useless
    rem_lbls = sequence_nums; rem_lbls = rem_lbls(bool_keep);
    
    rp = regionprops(BW, 'Centroid');
    centroids = cat(1,rp.Centroid);
    centroids = centroids(bool_keep(:), :); % remove centroids for vlaues that don't exist
    
    imshow(label2rgb(BW)); hold on;
    for n = 1:size(centroids,1)
        if strcmpi(location, 'centroid') 
            text(centroids(n,1), centroids(n,2), num2str(rem_lbls(n)), 'HorizontalAlignment', 'center', 'Color', 'white', 'BackgroundColor', 'black', 'FontSize', 10);
        elseif strcmpi(location, 'first') 
            [r,c] = find(BW == rem_lbls(n));
            text(c(1), r(1), num2str(rem_lbls(n)), 'HorizontalAlignment', 'center', 'Color', 'white', 'BackgroundColor', 'black', 'FontSize', 10);
        else
            error('Location not specified')
        end
    end
end