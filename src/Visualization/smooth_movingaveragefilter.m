function [smoothed_x, smoothed_y, outcome] = smooth_movingaveragefilter(x, y)
%function_smooth_movingaveragefilter Moving average filter
%   [smoothed_x, smoothed_y, outcome] = function_smooth_movingaveragefilter(x,y)
%   inputs
%      x: 1D array of length n
%      y: 1D array of length n
%   outputs
%      smoothed_x: 1D array of length m
%      smoothed_y: 1D array of length m
%      outcome: true if algorithm has been done successfully, false otherwise.
%
% Author: Francois L.E. Usseglio-Viretta, National Renewable Energy Laboratory (NREL)
% Original code modified specifically for this application by Alex Quinn (NREL).
%   We suggest strong consideration of filtering and moving averages (or
%   no filtering) of morphology, and thus reimplementation of this code.

%% PARAMETERS
number_point = length(unique(x)); % number of data points in vector - equals unique data points
minimum_array_length = 5;         % prevents small data sets from being smoothed
moving_rangeratio = 0.2;          % output array is 1/5 size of original x

s_warning = warning; % Save the current warning settings.
warning('on') % Enable all warnings.

%% CHECK PARAMETERS TYPE, BOUNDS and DIMENSION
% x and y
if ~isfloat(x) || ~isfloat(y)
    error('smooth_movingaveragefilter: 1st and 2nd arguments ''x'' and ''y'' must be a 1D array of same length.')
else
    if (isvector(x) && isvector(y) && numel(x) == numel(y))==false
        error('smooth_movingaveragefilter: 1st and 2nd arguments ''x'' and ''y'' must be a 1D array of same length.')
    end
end

% minimum_array_length
if ~isfloat(minimum_array_length) || numel(minimum_array_length)~=1 || round(minimum_array_length)~=minimum_array_length || minimum_array_length<1 
    error('smooth_movingaveragefilter: ''minimum_array_length'' must be positive integer.')
end
if length(x)<=minimum_array_length
    warning('smooth_movingaveragefilter: no smoothing performed as the array is too short.')
    smoothed_x = x; smoothed_y = y; outcome = false; warning(s_warning); return % Failure: no smoothing performed (output=input), but program continues.
end

% number_point
if ~isfloat(number_point) || numel(number_point)~=1 || round(number_point)~=number_point || number_point<1 
    error('smooth_movingaveragefilter: ''number_point'' must be positive integer.');
end

% moving_rangeratio and  moving_range
if ~isfloat(moving_rangeratio) || numel(moving_rangeratio)~=1
    error('smooth_movingaveragefilter: ''moving_rangeratio'' must be a number.')
else
    if moving_rangeratio>0 && moving_rangeratio<1
        r = round(moving_rangeratio*number_point); % Ratio of the array length
    else
        error 'smooth_movingaveragefilter: ''moving_rangeratio'' must be a real >0, <1.')
    end
end

r=max(r,2); % Enforce a minimum value
if mod(r,2)==0
    r=r+1; % even -> odd
end

if r>=number_point
    warning('smooth_movingaveragefilter: no smoothing performed as the range is too high.')
    smoothed_x = x; smoothed_y = y; outcome = false; warning(s_warning); return % Failure: no smoothing performed (output=input), but program continues.
end    

%% ALGORITHM
% x,y: initial array, length=n
% xx,yy: interpolated arrays, uniform spacing, length=number_point
% xx,yyy: averaged arrays, length=number_point
xx = linspace(x(1),x(end),number_point)'; % Uniformly spaced array (each point has the same weight for the subsequent average caluclation)
yy=interp1(x,y,xx); % Interpolate
yyy=zeros(number_point,1); % Initialize

% Moving average filter
r_ = (r-1)/2;
sum_= yy(r_+1:end-r_); % Initialize
for k=0:1:(r_-1)
    sum_ = sum_ +  yy(1+k : number_point-r+1+k);
end
for k=0:1:(r_-1)
    sum_ = sum_ +  yy(r-k : number_point-k);
end        
yyy(r_+1:end-r_) = sum_/r; % Average value

% keep origin behavior
for k=1:1:r_
    r__ = k-1;
    yyy(k) = sum(yy(k-r__:1:k+r__))/(2*r__+1);
end
for k=number_point-r_+1:1:number_point
    r__ = number_point-k;
    yyy(k) = sum(yy(k-r__:1:k+r__))/(2*r__+1);                
end

smoothed_x = xx;
smoothed_y = yyy;
 
outcome = true; % Success
warning(s_warning) % Restore the saved warning state structure

end

