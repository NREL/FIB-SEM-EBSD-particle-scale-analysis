function [fig, data, center_vertex, frames] =  function_hist3D_sph(th, phi, varargin)
%function_hist3D_sph 3D histogram visualization
%   [fig, D, CV] =  function_hist3D_sph(th, phi, shape_type, subdiv) 
%   Creates a spherical histogram by binning vectors directed from a
%   central point into approximate equal-area surfaces of a sphere 
%   (approximated using a platonic solid of choice). Bins of finer
%   resolution can be created by subdividing the platonic solid surfaces
%   into equal surface area triangles. This function wraps
%   'function_hist3D_xyz', which has very similar behavior but asks for
%   inputs in unit vectors of the directional data.
%   
%   Inputs
%       th - theta (radians), or azimutal angle, measured as angle from x-axis in
%          x-y plane (same convention as sph2cart).
%      phi - phi (radians), elevation angle from x-y plane (same convention as sph2cart)
%      shape_type - specifies one of the platonic solids in 'platonic_solid.m'
%      written by Kevin Mattheus Moerman. Shapes supported:
%          2 - Cube
%          4 - Icosahedron
%          5 - Dodecahedron
%       subdivisions - integer, subdivides non-trangular bins into triangles
%           using centroid as new vertex, and triangles into 4-traingles using loop
%           subdivision. Due to compounding nature, 4+ subdivisions will slow
%           performance.
% 
%   Outputs
%       fig - handle to figure of 3D histogram
%       data - column matrix of [bin#, count of vectors in bin, normalized
%           count, theta, phi]. Theta and phi point to centroid of bin.
%       center_vertex - unit vectors from origin pointing to center of each
%           bin
%       frames - cell array of 'frames' for rotating histogram. 
%           'ProduceVideo' parameter must be set to true, else returns {}.
%           FRM can be easily written to video using VideoWriter feature.
%           3D histogram rotates about z-axis (blue).
%   
%    Optional parameters
%       'ColorFaces' | true/false - applies colormap to faces of 3D histogram% 
%       'ShowLines' | true/false - plots indiviudal lines
%       'PlotMethod' | 'expansion' (default), 'extrusion', 'lines' -
%           multiple ways to visualize data
%       'BaseLine' | double from 0-1 - shifts basline from origin out
%           radially
%       'FaceVer' | array of integers in range [1, n], where n is number of
%           bins. Used to verify whether lines lie within created bin%           
%       'ProduceVideo' | true/false
%       'FilterFrequency' |  n = double from 0-1 - allows filtering of
%       frequencies > n
%       'Normalization' | integer - scales extrusion.
% 
%   Note: the binning accuracy has not been rigorously tested yet.
%
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Inspired by discussions with: Donal P. Finagan, NREL
%   Some idea generation with:  Francois Usseglio-Viretta, NREL

%% Default Values
    default_show_lines = false;
    default_color_faces = false;
    default_plot_method = 'expansion'; % 'extrusion', 'lines'
    default_baseline = 0;
    default_face_verification = [];
    default_produce_video = false;
    default_filter_frequency = 1.1;
    default_representation = 'icosahedron';
    default_subdivision = 0;
    default_normalization = NaN;
    
    p = inputParser;
    addRequired(p, 'th');
    addRequired(p, 'phi');
    addParameter(p, 'ColorFaces', default_color_faces); 
    addParameter(p, 'ShowLines', default_show_lines);
    addParameter(p, 'PlotMethod', default_plot_method);
    addParameter(p, 'BaseLine', default_baseline);
    addParameter(p, 'FaceVer', default_face_verification);
    addParameter(p, 'ProduceVideo', default_produce_video);
    addParameter(p, 'FilterFrequency', default_filter_frequency);
    addParameter(p, 'Representation', default_representation);
    addParameter(p, 'Subdivision', default_subdivision);
    addParameter(p, 'Normalization', default_normalization);
    parse(p,th,phi,varargin{:});
    
    th = p.Results.th;
    phi = p.Results.phi;
    show_lines = p.Results.ShowLines;
    color_faces = p.Results.ColorFaces;
    plot_method = p.Results.PlotMethod;
    base_line = p.Results.BaseLine;
    face_ver = p.Results.FaceVer;
    produce_video = p.Results.ProduceVideo;
    filter_frequency = p.Results.FilterFrequency;
    representation = p.Results.Representation;
    subdivision = p.Results.Subdivision;
    normalization = p.Results.Normalization;
    
    xyz = zeros(size(th,1),3);
    [xyz(:,1), xyz(:,2), xyz(:,3)] = sph2cart(th, phi, 1);    
    
    [fig, data, center_vertex, frames] =...
        function_hist3D_xyz(xyz,...
    'Representation', representation, ...
    'Subdivision', subdivision, ...
    'FilterFrequency', filter_frequency, ...
    'ColorFaces', color_faces, ...
    'PlotMethod', plot_method, ...
    'showlines', show_lines, ...
    'facever', face_ver, ...
    'baseline', base_line, ...
    'Normalization', normalization, ...
    'ProduceVideo', produce_video);

end