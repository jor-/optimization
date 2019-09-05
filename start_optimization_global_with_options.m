function start_optimization_global_with_options(optimization_dir, cost_function_name, min_measurements_standard_deviations, min_standard_deviations, min_measurements_correlations, correlation_decomposition_min_value_D, max_box_distance_to_water, node_kind, nodes, cpus)
% START_OPTIMIZATION_GLOBAL_WITH_OPTIONS executes a global optimization with predefined options.
%
% Example:
%     START_OPTIMIZATION_GLOBAL_WITH_OPTIONS(OPTIMIZATION_OUTPUT_DIR, COST_FUNCTION_NAME, MIN_MEASUREMENTS_STANDARD_DEVIATIONS, MIN_STANDARD_DEVIATIONS, MIN_MEASUREMENTS_CORRELATIONS, correlation_decomposition_min_value_D, MAX_BOX_DISTANCE_TO_WATER, NODE_KIND, NODES, CPUS)
%
% Input:
%     OPTIMIZATION_DIR: The directory where to save informations about the optimization run.
%         type: str
%     COST_FUNCTION_NAME: The cost function which should be evaluated.
%         type: str
%     MIN_MEASUREMENTS_STANDARD_DEVIATIONS: The numbers of minimal measurements used to calculate standard deviations.
%         type: int vector (non-negative)
%         optional: Default value used if empty.
%     MIN_STANDARD_DEVIATIONS: The minimal standard deviations assumed for the measurement errors.
%         type: float vector (non-negative)
%         optional: Default value used if empty.
%     MIN_MEASUREMENTS_CORRELATIONS: The numbers of minimal measurements used to calculate correlations.
%         type: int vector (non-negative)
%         optional: Default value used if empty.
%     correlation_decomposition_min_value_D: The minimal standard deviations assumed for the measurement errors.
%         type: float (between 0 and 1)
%         optional: Default value used if empty.
%     MAX_BOX_DISTANCE_TO_WATER: The maximal allowed box distance to water used to determine valid measurements.
%         type: int (non-negative)
%         optional: All measurements are used if empty.
%     NODE_KIND: The node kind to use for the spinup.
%         type: str
%         optional: Default value used if empty.
%     NODES: The number of nodes to use for the spinup.
%         type: int (positive)
%         optional: Default value used if empty.
%     CPUS: The number of cpus to use for the spinup.
%         type: int (positive)
%         optional: Default value used if empty.
%
%   Copyright (C) 2011-2019 Joscha Reimer jor@informatik.uni-kiel.de

    %% init cost function options
    cost_function_options_object = cost_function_options();
    
    %% cost function options
    cost_function_options_object.cost_function_name = cost_function_name;
    
    %% measurement options
    if nargin >= 3
        cost_function_options_object.max_box_distance_to_water = max_box_distance_to_water;
    end
    if nargin >= 4
        cost_function_options_object.min_measurements_standard_deviations = min_measurements_standard_deviations;
    end
    if nargin >= 5
        cost_function_options_object.min_standard_deviations = min_standard_deviations;
    end
    if nargin >= 6
        cost_function_options_object.min_measurements_correlations = min_measurements_correlations;
    end
    if nargin >= 7
        cost_function_options_object.correlation_decomposition_min_value_D = correlation_decomposition_min_value_D;
    end
    
    %% node setup options
    if nargin >= 8
        cost_function_options_object.nodes_setup_node_kind = node_kind;
    end
    if nargin >= 9
        cost_function_options_object.nodes_setup_number_of_nodes = nodes;
    end
    if nargin >= 10
        cost_function_options_object.nodes_setup_number_of_cpus = cpus;
    end
    
    %% email
    cost_function_options_object.error_email_address = 'jor@informatik.uni-kiel.de';
    
    %% model options
    config_dir = [optimization_dir '/config'];
    file = [config_dir '/model_name.txt'];
    model_name = importdata(file);
    model_name = model_name{1,1};
    
    cost_function_options_object.model_name = model_name;
    cost_function_options_object.time_step = 1;
    
    %% spinup options
    file = [config_dir '/spinup.txt'];
    try
        spinup_configs = load(file);
        cost_function_options_object.spinup_years = spinup_configs(1);
        cost_function_options_object.spinup_tolerance = spinup_configs(2);
        cost_function_options_object.spinup_satisfy_years_and_tolerance = spinup_configs(3);
    catch
        disp(['File ' file ' was not found. Using default configurations.'])
    end
    
    %% derivative options
    file = [config_dir '/derivative.txt'];
    try
        derivative_configs = load(file);
        cost_function_options_object.derivative_accuracy_order = derivative_configs(1);
        cost_function_options_object.derivative_step_size = derivative_configs(2);
        cost_function_options_object.derivative_years = derivative_configs(3);
    catch
        disp(['File ' file ' was not found. Using default configurations.'])
    end
    
    %% model parameter tolerance options
    file = [config_dir '/model_parameters_relative_tolerance.txt'];
    try
        cost_function_options_object.model_parameters_relative_tolerance = load(file);
    catch
        disp(['File ' file ' was not found. Using default configurations.'])
    end
    file = [config_dir '/model_parameters_absolute_tolerance.txt'];
    try
        cost_function_options_object.model_parameters_absolute_tolerance = load(file);
    catch
        disp(['File ' file ' was not found. Using default configurations.'])
    end
    
    %% initial concentration with tolerance options
    file = [optimization_dir '/initial_concentrations.txt'];
    try
        cost_function_options_object.initial_concentrations= load(file);
    catch
        file = [config_dir '/initial_concentrations.txt'];
        try
            cost_function_options_object.initial_concentrations = load(file);
        catch
            disp(['File ' file ' was not found. Using default configurations.'])
        end
    end
    file = [config_dir '/initial_concentrations_relative_tolerance.txt'];
    try
        cost_function_options_object.initial_concentrations_relative_tolerance = load(file);
    catch
        disp(['File ' file ' was not found. Using default configurations.'])
    end
    file = [config_dir '/initial_concentrations_absolute_tolerance.txt'];
    try
        cost_function_options_object.initial_concentrations_absolute_tolerance = load(file);
    catch
        disp(['File ' file ' was not found. Using default configurations.'])
    end
    
    
    
    %% init optimization options
    optimization_options_object = struct();
    optimization_options_object.output_dir = optimization_dir;
    
    %% load global optimization options
    file = [config_dir '/global_optimization.txt'];
    try
        global_optimization_configs = load(file);
        optimization_options_object.global_trial_points = global_optimization_configs(1);
        optimization_options_object.global_stage_one_fun_evals = global_optimization_configs(2);
        optimization_options_object.global_max_wait_cycles = global_optimization_configs(3);
    catch
        disp(['File ' file ' was not found. Using default configurations.'])
    end
    optimization_options_object.global_distance_threshold_factor = 0.75;
    optimization_options_object.global_penalty_threshold_factor = 0.2;
    optimization_options_object.global_basin_radius_factor = 0.2;
    
    %% default options
    optimization_options_object.p_tol = 10^(-5);
    optimization_options_object.local_max_fun_evals = 200;  
    
    %% load parameter options
    try
        optimization_options_object.p0 = load([optimization_dir '/p0.txt']);
    catch
        optimization_options_object.p0 = load([config_dir '/p0.txt']);
    end
    try
        p_b = load([optimization_dir '/pb.txt']);
    catch
        p_b = load([config_dir '/pb.txt']);
    end
    optimization_options_object.p_lb = p_b(:,1);
    optimization_options_object.p_ub = p_b(:,2);
    
    %% print options
    cost_function_options_object
    optimization_options_object
    
    %% run
    optimization_global(cost_function_options_object, optimization_options_object);

    exit;
end


