function results_d = function_prob_density_function_wrapper(a)
    parameters.round_value = 0;
    parameters.smooth_cumulative_fct = true;
    parameters.minimum_array_length = 5;
    parameters.number_point = length(unique(a));
    parameters.moving_range = 0;
    parameters.moving_rangeratio = 0.2; % Range of the average filter (0 to 1)
    parameters.enforce_samelength = false;
    parameters.origin = 'symmetrical';
    parameters.boundary_behavior = 'keep origin';   
    [results_d, ~] = Function_probability_density(a,[],parameters);
end