function [results, outcome] = prob_density(x)
%Function_probability_density Calculate cumulative function and probability density function
%   [smoothed_x, smoothed_y, outcome] = Function_probability_density(x,w,parameters)
%   or
%   [smoothed_x, smoothed_y, outcome] = Function_probability_density(x,w)
%   inputs
%      x: 1D array of length n (value)
%
% Author: Francois L.E. Usseglio-Viretta, National Renewable Energy Laboratory (NREL)
% Original code modified specifically for this application by Alex Quinn (NREL).
%   We suggest strong consideration of the calculation involved in
%   probability density functions (if one chooses this method of data 
%   reporting) of morphology, and thus reimplementation of this code. 


%% CHECK INPUT
% x and w
if ~isfloat(x)
    error('prob_density: argument ''x'' must be a 1D array (value).')
else
    if isvector(x)==false
        error('prob_density: argument ''x'' must be a 1D array (value).')
    end
end

%% CALCULATE THE SUM FUNCTION
results.smoothed_cumulative_fct = []; % Initialize
results.smoothed_x50 = [];
results.smoothed_probability_density_fct = [];
results.integral_smoothed_probability_density_fct = [];

w = x*0+1; % Everything is weighted to 1.

[results.cumulative_fct, results.x50] = calculate_cumulative_fct (x, w);

% smooth by moving average
[smoothed_x, smoothed_y, outcome_smoothing] = smooth_movingaveragefilter(results.cumulative_fct(:,1),results.cumulative_fct(:,2));
if outcome_smoothing
    results.smoothed_cumulative_fct = [smoothed_x smoothed_y];
    results.smoothed_x50 = interp1(results.smoothed_cumulative_fct(:,2),results.smoothed_cumulative_fct(:,1),0.5);
end

%% CALCULATE THE PROBABILITY DENSITY FUNCTION
[results.probability_density_fct, results.integral_probability_density_fct] = calculate_probability_density_fct(results.cumulative_fct(:,1),results.cumulative_fct(:,2));
if ~isempty(results.smoothed_cumulative_fct)
    [results.smoothed_probability_density_fct, results.integral_smoothed_probability_density_fct] = calculate_probability_density_fct(results.smoothed_cumulative_fct(:,1),results.smoothed_cumulative_fct(:,2));
else
    results.smoothed_probability_density_fct = [];
    results.integral_smoothed_probability_density_fct = [];
end

outcome = true; % Success

%% FUNCTIONS
    function [cumulative_fct, x50] = calculate_cumulative_fct (x,w)
        
        unique_ = unique(x); % Unique values
        cumulative_fct = zeros(length(unique_),2); % Initialisation (x, cumulative fct, smoothed cumulative fct)
        cumulative_fct(:,1)=unique_;        
        % Step 1: probability randomly chosen point p from the array a of lenght n is equal with the unique values v
        pdi_=zeros(length(unique_),2);
        pdi_(:,1)=unique_;
        all_weight = unique(w);
        if length(all_weight)==1 && all_weight==1
            number_element=numel(x);
            for current_value=1:1:length(unique_)
                pdi_(current_value,2)= sum(sum(sum( x==unique_(current_value) ))) / number_element;
            end
        else
            total_weight = sum(w);
            for current_value=1:1:length(unique_)
                idx = find(x==unique_(current_value));
                pdi_(current_value,2)= sum(sum(sum( w(idx) ))) / total_weight;
            end            
        end
        % Step 2: The sum function P(D)= 1-(P(0<=d<=D)=sum(p(di)), di<=D)
        % Much faster: start from the last value
        cumulative_fct(end,2)=pdi_(end,2);
        for current_value=length(unique_)-1:-1:1
            cumulative_fct(current_value,2)=cumulative_fct(current_value+1,2)+pdi_(current_value,2);
        end
        % Find x50.
        x50 = interp1(cumulative_fct(:,2),cumulative_fct(:,1),0.5);
    end

    function [probability_density_fct, integral_pdf] = calculate_probability_density_fct (x, cumulative_fct)
        n_=length(x);
        probability_density_fct = zeros(n_,2); % Initialize
        integral_pdf=0;
        if n_>1
            f_=cumulative_fct; % For visibility sake
            for current_=2:1:n_-1
                probability_density_fct(current_,2)= (f_(current_+1)-f_(current_-1))/(x(current_+1)-x(current_-1));
            end
            probability_density_fct(1,2)= (f_(2)-f_(1))/(x(2)-x(1));
            probability_density_fct(n_,2)= (f_(n_)-f_(n_-1))/(x(n_)-x(n_-1));
            probability_density_fct(:,2)=-probability_density_fct(:,2);
            probability_density_fct(:,1) = x;
            integral_pdf = trapz(probability_density_fct(:,1),probability_density_fct(:,2)); % Probability density function integral (should be equal to 1)
        end
    end
end