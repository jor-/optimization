function start_optimization_global_with_options(cost_function_kind, optimization_output_dir, config_dir, node_kind, nodes, cpus)
% START_OPTIMIZATION_GLOBAL_WITH_OPTIONS executes a global optimization with predefined options.
%
% Example:
%     START_OPTIMIZATION_GLOBAL_WITH_OPTIONS(COST_FUNCTION_KIND, OPTIMIZATION_OUTPUT_DIR, CONFIG_DIR, NODE_KIND, NODES, CPUS)
%
% Input:
%     COST_FUNCTION_KIND: The cost function which should be evaluated.
%         type: str
%     OPTIMIZATION_OUTPUT_DIR: The directory where to save informations about the optimization run.
%         type: str
%     CONFIG_DIR: The directory where to find the optimization options.
%         type: str
%     NODE_KIND: The node kind to use for the spinup.
%         type: str
%     NODES: The number of nodes to use for the spinup.
%         type: int
%     CPUS: The number of cpus to use for the spinup.
%         type: int
%
%   Copyright (C) 2011-2015 Joscha Reimer jor@informatik.uni-kiel.de

    %% init cost function options
    cost_function_options_object = cost_function_options();
    cost_function_options_object.cost_function_kind = cost_function_kind;
    if nargin >= 4
        cost_function_options_object.nodes_setup_node_kind = node_kind;
    end
    if nargin >= 5
        cost_function_options_object.nodes_setup_number_of_nodes = nodes;
    end
    if nargin >= 6
        cost_function_options_object.nodes_setup_number_of_cpus = cpus;
    end
    
    %% load spinup options
    spinup_configs = load([config_dir '/spinup.txt']);
    cost_function_options_object.spinup_years = spinup_configs(1);
    cost_function_options_object.spinup_tolerance = spinup_configs(2);
    cost_function_options_object.spinup_satisfy_years_and_tolerance = spinup_configs(3);
    
    %% load parameter tolerance options
    cost_function_options_object.parameters_relative_tolerance = load([config_dir '/parameters_relative_tolerance.txt']);
    cost_function_options_object.parameters_absolute_tolerance = load([config_dir '/parameters_absolute_tolerance.txt']);
    
    %% load derivative options
    derivative_configs = load([config_dir '/derivative.txt']);
    cost_function_options_object.derivative_accuracy_order = derivative_configs(1);
    cost_function_options_object.derivative_step_size = derivative_configs(2);
    cost_function_options_object.derivative_years = derivative_configs(3);
    
    %% init error options
    cost_function_options_object.error_email_address = 'jor@informatik.uni-kiel.de';
    
    %% init cost function options
    optimization_options_object = struct();
    optimization_options_object.output_dir = optimization_output_dir;
    
    %% load global optimization options
    global_optimization_configs = load([config_dir '/global_optimization.txt']);
    optimization_options_object.global_trial_points = global_optimization_configs(1);
    optimization_options_object.global_stage_one_fun_evals = global_optimization_configs(2);
    optimization_options_object.global_max_wait_cycles = global_optimization_configs(3);
    optimization_options_object.global_distance_threshold_factor = 0.75;
    optimization_options_object.global_penalty_threshold_factor = 0.2;
    optimization_options_object.global_basin_radius_factor = 0.2;
    
    %% default configs
    optimization_options_object.p_tol = 10^(-5);
    optimization_options_object.local_max_fun_evals = 200;  
    
    %% load parameter options
    optimization_options_object.p0 = load([config_dir '/p0.txt'])';
    p_b = load([config_dir '/pb.txt']);
    optimization_options_object.p_lb = p_b(1,:);
    optimization_options_object.p_ub = p_b(2,:);
    
    %% print options
    cost_function_options_object
    optimization_options_object
    
    %% run
    optimization_global(cost_function_options_object, optimization_options_object);

    exit;
end


