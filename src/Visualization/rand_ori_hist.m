function [angle_, N, edges_new] = rand_ori_hist(n, count)
%rand_ori_hist computes the distribution of angles between randomly
%oriented grains. All grains are assumed to share the same surface area
%with each bordering grain. All grains are assumed to the same shape and
%size, and tesselated in the same pattern (for example, cubes stacked in
%the x-y-z directions and all randomly assigned orientations).
%   
%   Inputs
%       n - amount of boundaries to simulate
%       count - matrix of numeric values
% 
%   Outputs
%       angle_ - list of angles produced in simulation
%       N - height normalized probablilty distribution
%       edges_new - angles (x-positions) for N
%   
%   Author: Alexander H Quinn, National Renewable Energy Laboratory (NREL)
%   Guided/Inspired by: Donal P. Finagan, NREL
%   Additional assistance:  Francois Usseglio-Viretta, NREL

% randomly oriented directions - equivalent to problem of "random
% distribution of points on a sphere surface"
% normal distributions "has radial symmetry" (trivariate normal distribution)

xyz1 = randn(n,3); 
xyz1 = xyz1./sqrt(sum(xyz1.^2,2));
xyz2 = randn(n,3);
xyz2 = xyz2./sqrt(sum(xyz2.^2,2));

angle_ = zeros(length(xyz1),1);
for k = 1:1:length(xyz1)
    x = xyz1(k,:);
    y = xyz2(k,:);
    angle_(k) =  rad2deg (2*atan2(  norm( x*norm(y) - norm(x)*y) , norm( x*norm(y) + norm(x)*y) ) );
    
    if angle_(k) > 90 % angles > 90 have an equivalent direction (theta - 90)
        angle_(k) = angle_(k) - 90;
    end
end

[N, edges] = histcounts(angle_, 45);
edges_new = (edges(2:end) + edges(1:end-1))/2;

N_tot = sum(N);
ratio = count/N_tot;
N = N*ratio;
end