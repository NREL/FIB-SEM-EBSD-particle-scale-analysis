function R = calc_R(phi1, cap_phi, phi2)
%calc_R creates rotation matrix from Euler Bunge Data
%   R = calc_R(phi1, cap_phi, phi2) returns matrix for
%       intrinstic rotation of column vectors representing direction in 3D
%       space. Use like R*[x;y;z]
%   
%   Inputs
%       phi1 - phi1
%       cap_phi - matrix of cap_phi
%       phi2 - smatrix of phi2
% 
%   Outputs
%       R - rotation matrix that can applied on RHS of [u v w] row vector
%           or matrix of multiple uvw row vectors each indicating
%           crystallographic direction
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

    Rz = [cos(phi1), sin(phi1), 0;-sin(phi1), cos(phi1), 0;0, 0, 1];
    Rx = [1, 0, 0;0, cos(cap_phi), sin(cap_phi); 0, -sin(cap_phi), cos(cap_phi)];
    Rz2 = [cos(phi2), sin(phi2), 0;-sin(phi2), cos(phi2), 0;0, 0, 1];
    R = Rz*Rx*Rz2;
end