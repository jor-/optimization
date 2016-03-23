function optimization_global(cost_function_opts, optimization_opts)
% OPTIMIZATION_GLOBAL executes a global optimization.
%
% Example:
%     OPTIMIZATION_GLOBAL(COST_FUNCTION_OPTS, optimization_opts)
%
% Input:
%     COST_FUNCTION_OPTS: The options for the cost function evaluation.
%         type: cost_function_opts
%     optimization_opts: The options for the optimization.
%         type: struct
%     supported valued in optimization_opts:
%     OUTPUT_DIR: The directory where to save informations about the optimization run.
%         type: str
%     P0: The parameter vector from which to start the optimization.
%         type: float vector (of len n)
%     P_LB: The lower bound for the optimization.
%         type: float vector (of len n)
%     P_UB: The upper bound for the optimization.
%         type: float vector (of len n)
%     P_TOL: The tolerance for which to terminate the optimization.
%         type: float
%     LOCAL_MAX_FUN_EVALS: Maximal number of function evaluations for a local optimization.
%         type: int
%     GLOBAL_TRIAL_POINTS: Number of potenzial start points for the global optimization.
%         type: int
%     GLOBAL_STAGE_ONE_FUN_EVALS: Number of examined start points at phase one for the global optimization.
%         type: int
%     GLOBAL_MAX_WAIT CYCLES: Option for the global optimization algorithm.
%         type: int
%     GLOBAL DISTANCE THRESHOLD_FACTOR: Option for the global optimization algorithm.
%         type: float
%     GLOBAL_PENALTY_THRESHOLD_FACTOR: Option for the global optimization algorithm.
%         type: float
%     GLOBAL_BASIN_RADIUS_FACTOR: Option for the global optimization algorithm.
%         type: float
%
%   Copyright (C) 2011-2016 Joscha Reimer jor@informatik.uni-kiel.de
    
    %% init dirs    
    exchange_dir = [optimization_opts.output_dir '/exchange_matlab_python'];
    [~,~,~] = mkdir(exchange_dir);
    cost_function_opts.exchange_dir = exchange_dir;
    iterations_dir = [optimization_opts.output_dir '/iterations'];
    [~,~,~] = mkdir(iterations_dir);
    
    %% init files
    results_file = [optimization_opts.output_dir '/results.mat'];
    options_file = [optimization_opts.output_dir '/options.mat'];
    all_iterations_file = [iterations_dir '/all_iterations.mat'];
    solver_iterations_file = [iterations_dir '/solver_iterations.mat'];
    
    %% init iteration
    all_iteration_index = 0;
    all_p_iteration{1} = [];
    all_f_iteration{1} = [];
    
    solver_iteration_index = 0;
    solver_p_iteration{1} = [];
    solver_f_iteration{1} = [];
    solver_evals_f_iteration{1} = [];
    
    scale=1;
    
    if scale
        %% init cost function
        cost_function_object = cost_function_scalable(cost_function_opts, optimization_opts.p_lb, optimization_opts.p_ub);
        
        %% scale parameters
        p0 = cost_function_object.p_scale(optimization_opts.p0);
        p_lb = cost_function_object.p_scale(optimization_opts.p_lb);
        p_ub = cost_function_object.p_scale(optimization_opts.p_ub);
        
        %% scale cost function
        f0 = cost_function_object.eval(p0);
        cost_function_object.f_scaling_factor = 1 / f0;
        
    else
        %% init cost function
        cost_function_object = cost_function(cost_function_opts);
        
        %% get parameters
        p0 = optimization_opts.p0;
        p_lb = optimization_opts.p_lb;
        p_ub = optimization_opts.p_ub;
    end
    
    %% configure solver
    opt = optimoptions(@fmincon, 'Algorithm', 'sqp', 'GradObj', 'on', 'TolCon', eps, 'TolX', optimization_opts.p_tol, 'MaxFunEvals', optimization_opts.local_max_fun_evals, 'OutputFcn', @solver_save_iterations, 'ScaleProblem', 'obj-and-constr', 'ObjectiveLimit', eps, 'Display', 'iter-detailed', 'Diagnostics', 'on', 'FunValCheck', 'on')
    problem = createOptimProblem('fmincon', 'objective', @cost_function_eval_with_save_iterations, 'x0', p0, 'lb', p_lb, 'ub', p_ub, 'options', opt)
    solver = GlobalSearch('Display', 'iter', 'StartPointsToRun', 'bounds', 'TolX', optimization_opts.p_tol, 'NumStageOnePoints', optimization_opts.global_stage_one_fun_evals, 'NumTrialPoints', optimization_opts.global_trial_points, 'MaxWaitCycle', optimization_opts.global_max_wait_cycles, 'DistanceThresholdFactor', optimization_opts.global_distance_threshold_factor, 'PenaltyThresholdFactor', optimization_opts.global_penalty_threshold_factor, 'BasinRadiusFactor', optimization_opts.global_basin_radius_factor)

    %% save options
    save(options_file)

    %% run solver
    [p_min, f_min, exit_flag, output, solutions] = run(solver, problem)
    
    
    if scale
        p_min = cost_function_object.p_unscale(p_min)
    end

    %% save results
    save(results_file)      
    
    
    %% cost function iteration saving function
    function [f, df] = cost_function_eval_with_save_iterations(p)
        if all_iteration_index == 0 || ~ all(all_p_iteration{all_iteration_index} == p)
            all_iteration_index = all_iteration_index + 1;
        end
        
        all_p_iteration{all_iteration_index} = p;
        save(all_iterations_file, 'all_p_iteration', 'all_f_iteration');
        
        file_suffix = [sprintf('%03i', all_iteration_index - 1) '.txt'];
        iteration_p_file = [iterations_dir '/all_p_' file_suffix];
        p = p';
        save(iteration_p_file, 'p', '-ascii', '-double') ;
        p = p';
        
        if nargout == 2
            [f, df] = cost_function_object.eval(p);
        else
            f = cost_function_object.eval(p);
        end
        
        all_f_iteration{all_iteration_index} = f;
        save(all_iterations_file, 'all_p_iteration', 'all_f_iteration');
        
        iteration_f_file = [iterations_dir '/all_f_' file_suffix];
        save(iteration_f_file, 'f', '-ascii', '-double');
        if nargout == 2
            iteration_df_file = [iterations_dir '/all_df_' file_suffix];
            save(iteration_df_file, 'df', '-ascii', '-double');
        end
    end
    
   
    %% solver iteration saving function
    function stop = solver_save_iterations(x, optimValues, state)
        p = all_p_iteration{all_iteration_index};
        f = all_f_iteration{all_iteration_index};
        
        if solver_iteration_index == 0 || ~ all(solver_p_iteration{solver_iteration_index} == p)
            solver_iteration_index = solver_iteration_index + 1;
        end
        
        solver_p_iteration{solver_iteration_index} = p;
        solver_f_iteration{solver_iteration_index} = f;
        solver_evals_f_iteration{solver_iteration_index} = all_iteration_index;
        save(solver_iterations_file, 'solver_p_iteration', 'solver_f_iteration', 'solver_evals_f_iteration');
        
        file_suffix = [sprintf('%03i', solver_iteration_index - 1) '.txt'];
        p = p';
        iteration_p_file = [iterations_dir '/solver_p_' file_suffix];
        save(iteration_p_file, 'p', '-ascii', '-double') ;
        iteration_f_file = [iterations_dir '/solver_f_' file_suffix];
        save(iteration_f_file, 'f', '-ascii', '-double');
        eval_f_index = all_iteration_index - 1;
        iteration_evals_f_file = [iterations_dir '/solver_eval_f_index_' file_suffix];
        save(iteration_evals_f_file, 'eval_f_index', '-ascii', '-double');
        
        stop = 0;
    end
end
