%% Description
% Misc. supplemental information Figures.

addpath('Inputs')
addpath('GrainProps Outputs')

% move to SI
load('2020-01-12-15-03-16_EBSD_03_mfv.mat');
gp_mfv = grain_props; close all;

%% Grain-grain angles per boundary pixel - move to SI
if ~isempty(gp_mfv.grain_border_angles)
    f100 = figure; histogram(real(gp_mfv.grain_border_angles(:,5)), 72); xlabel('g-misorientation (degrees)'); ylabel('Frequency')
    function_show_border_angles(gp_mfv, gp_mfv.grain_border_angles);
    f100.Color = 'white'; f100.Units = 'inches'; f100.Position(3) = 2.75; f100.Position(4) = 2.25;
end