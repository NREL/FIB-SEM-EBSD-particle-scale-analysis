%% Description
% Misc. supplemental information Figures.

addpath('Inputs')
addpath('GrainProps Outputs')
addpath('Visualization')
addpath('3DHistogram')

%% Loading
load('gp_grain_orientation_most_frequent.mat');
gp_mfv = grain_props; close all;

%% Grain-grain angles per boundary pixel for Averaged Grains Angles
if ~isempty(gp_mfv.grain_border_angles)
    f100 = figure; histogram(real(gp_mfv.grain_border_angles(:,5)), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    show_border_angles(gp_mfv, gp_mfv.grain_border_angles);
    f100.Color = 'white'; f100.Units = 'inches'; f100.Position(3) = 2.75; f100.Position(4) = 2.25;
end

%% 3D Histograms for SI Visualization
% one direction, 3 vectors
num = 3;
rep_pattern = [1,1,1];
C = repmat(rep_pattern,num,1);
fig1 = hist3D_wrapper(C, 0.4, 15);
view([55 25]);
zoom(1.7);

% one direction, 15 vectors
num = 15;
rep_pattern = [1,1,1];
C = repmat(rep_pattern,num,1);
fig2 = hist3D_wrapper(C, 0.4, 15);
view([55 25]);
zoom(1.7);

% two directions 
num = 7;
rep_pattern = [1,1,1; -1,-1,1];
C = repmat(rep_pattern,num,1);
fig3 = hist3D_wrapper(C, 0.4, 15);
view([55 25]);
zoom(1.7);

% many directions
rep_pattern = randn(100,3);
rep_pattern = rep_pattern(rep_pattern(:,3) > 0, :); % only +z allowed
C = repmat(rep_pattern,num,1);
fig4 = hist3D_wrapper(C, 0.4, NaN);
view([135, 0])

% many directions uniform
rep_pattern = randn(120000,3);
rep_pattern = rep_pattern(rep_pattern(:,3) > 0, :); % only +z allowed
C = repmat(rep_pattern,num,1);
fig5 = hist3D_wrapper(C, 0.4, NaN);
view([135, 0])

%% xyz axis
fig5 = hist3D_wrapper(C, 0.01, 1000);

%% 3D Histograms Subdivision
C = []
hist3D_wrapper_subdv(C, 0)
hist3D_wrapper_subdv(C, 1)
hist3D_wrapper_subdv(C, 2)
hist3D_wrapper_subdv(C, 3)



function fig = hist3D_wrapper(C, baseline, normalization)
[fig, ~] = function_hist3D_xyz(C,...
    'Representation', 'icosahedron',...
    'Subdivision', 1,...
    'ColorFaces', true, ...
    'PlotMethod', 'extrusion', ... % default, (above is 
    'BaseLine', baseline,...
    'Normalization', normalization); % baseline modifies origin location (0 = origin)
    a = gca;
    a.Children(5).Clipping = 'off'; % allows for zooming into histogram
    a.Children(6).Clipping = 'off';
    a.Children(3).Clipping = 'off';
    a.Children(4).Clipping = 'off';
    a.Children(2).Clipping = 'off';
    lighting none;
end

function fig = hist3D_wrapper_subdv(C, subdv)
[fig, ~] = function_hist3D_xyz(C,...
    'Representation', 'icosahedron',...
    'Subdivision', subdv,...
    'ColorFaces', true, ...
    'PlotMethod', 'extrusion', ... % default, (above is 
    'BaseLine', 1,...
    'Normalization', 1); % baseline modifies origin location (0 = origin)
    a = gca;
    a.Children(5).Clipping = 'off'; % allows for zooming into histogram
    a.Children(6).Clipping = 'off';
    a.Children(3).Clipping = 'off';
    a.Children(4).Clipping = 'off';
    a.Children(2).Clipping = 'off';
    lighting none;
end