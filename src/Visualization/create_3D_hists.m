function fig = create_3D_hists(grain_props)



xyz_pos_for_reshape = grain_props.xyz_cleaned;
for n = 1:size(xyz_pos_for_reshape,3)
    temp_mat = xyz_pos_for_reshape(:,:,n);
    temp_mat(grain_props.BW == 0) = NaN; % ignore noise regions
    xyz_pos_for_reshape(:,:,n) = temp_mat;
end
A = permute(xyz_pos_for_reshape, [3,1,2]); % want to acquire data along column, 3 is of interest (x,y,z values)
B = reshape(A,3,size(A,2)*size(A,3)); % reshape into 3xlength
C = B'; %this can be used in directional histogram
C(isnan(C(:,1)), :) = [];

[fig, ~] = function_hist3D_xyz(C,...
    'Representation', 'icosahedron',...
    'Subdivision', 1,...
    'ColorFaces', true, ...
    'PlotMethod', 'extrusion', ... % default, (above is 
    'BaseLine', 0.4,...
    'Normalization', 33562); % baseline modifies origin location (0 = origin)
    a = gca;
    a.Children(5).Clipping = 'off';
    a.Children(6).Clipping = 'off';
    a.Children(3).Clipping = 'off';
    a.Children(4).Clipping = 'off';
    a.Children(2).Clipping = 'off';
end