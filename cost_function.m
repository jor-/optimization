classdef cost_function < handle
% COST_FUNCTION represents the cost function.
%
% COST_FUNCTION Methods:
%     COST_FUNCTION - creates a COST_FUNCTION object.
%     EVAL - evaluates the cost function.
%
%   Copyright (C) 2011-2019 Joscha Reimer jor@informatik.uni-kiel.de
    
    properties (Access = protected)
        options;
    end
    
    properties (Constant)
        parameter_filename = 'p.mat';
        f_filename = 'f.mat';
        df_filename = 'df.mat';
        output_filename = 'out.txt';

        database_run_command = [getenv('SIMULATION_OUTPUT_DIR') '/access'];
    end
    
    methods (Access = public)
        
        function self = cost_function(options)
        % COST_FUNCTION creates a COST_FUNCTION object.
        %
        % Example:
        %     OBJ = COST_FUNCTION(OPTIONS)
        %
        % Input:
        %     OPTIONS: The options used for the cost function evaluations.
        %         type: cost_function_options
        %
        % Output:
        %     OBJ: a COST_FUNCTION object with the passed configurations
        %
        % see also COST_FUNCTION_OPTIONS
        %
            
            % set options
            self.options = options;        
            
        end
        
        
        function [f, df] = eval(self, p)
        % EVAL evaluates the cost function.
        %
        % Example:
        %     F = COST_FUNCTION_OBJECT.EVAL(P)
        %     or
        %     [F, DF] = COST_FUNCTION_OBJECT.EVAL(Pd)
        %
        % Input:
        %     P: The parameters where to evaluate the cost function.
        %         type: float vector (of len n)
        %
        % Output:
        %     F: the value of the cost function 
        %         type: float
        %     DF: the value of the derivative of the cost function 
        %         type: float vector (of len n)
        %
        
            %% save parameters
            parameter_file = [self.options.exchange_dir '/' self.parameter_filename];
            save(parameter_file, 'p', '-v7');
            
            %% save acccess command
            eval_f = nargout >= 1;
            eval_df = nargout == 2;
            command = self.database_command(eval_f, eval_df);
            run_file = [self.options.exchange_dir '/' 'run.sh'];
            fid = fopen(run_file, 'w');
            fprintf(fid, '%s\n', command);
            fclose(fid);
            status = system(['chmod u+x ' run_file]);
            self.handle_error(status, true, false, true, true);
            
            %% execute access command
            status = 1;
            while status ~= 0
                status = system(run_file);
                self.handle_error(status, true, false, true, true);
            end
            
            %% load values
            f_file = [self.options.exchange_dir '/' self.f_filename];
            f = load(f_file);
            f = f.f;
            
            if nargout == 2
                df_file = [self.options.exchange_dir '/' self.df_filename];
                df = load(df_file);
                df = df.df;
            end
        end
        
    end
    
    
    methods (Access = protected)
        
        function command = database_command(self, eval_f, eval_df)
        % DATABASE_COMMAND returns the appropriate database access command.
        %
        % Example:
        %     COMMAND = COST_FUNCTION_OBJECT.DATABASE_COMMAND()
        %
        % Input:
        %     EVAL_F: Whether the cost function should be evaluated.
        %         type: boolean
        %     EVAL_DF: Whether the derivative of the cost function should be evaluated.
        %         type: boolean
        %
        % Output:
        %     COMMAND: the database access command
        %         type: str
        %
        
            options_str = '';
            options_str = [options_str ' --cost_function_name ' self.options.cost_function_name];
            options_str = [options_str ' --exchange_dir ' self.options.exchange_dir];
            options_str = [options_str ' --debug_logging_file ' self.options.exchange_dir '/' self.output_filename];
            

            if ~ isempty(self.options.max_box_distance_to_water)
                options_str = [options_str ' --max_box_distance_to_water ' int2str(self.options.max_box_distance_to_water)];
            end
            
            if ~ isempty(self.options.min_measurements_standard_deviations)
                options_str = [options_str ' --min_measurements_standard_deviations ' int2str(self.options.min_measurements_standard_deviations)];
            end
            
            if ~ isempty(self.options.min_measurements_correlations)
                options_str = [options_str ' --min_measurements_correlations ' int2str(self.options.min_measurements_correlations)];
            end
            
            if ~ isempty(self.options.min_standard_deviations)
                options_str = [options_str ' --min_standard_deviations ' num2str(self.options.min_standard_deviations)];
            end
            
            if ~ isempty(self.options.correlation_decomposition_min_value_D)
                options_str = [options_str ' --correlation_decomposition_min_value_D ' num2str(self.options.correlation_decomposition_min_value_D)];
            end

            
            if ~ isempty(self.options.model_name)
                options_str = [options_str ' --model_name ' self.options.model_name];
            end
            
            if ~ isempty(self.options.initial_concentrations)
                options_str = [options_str ' --initial_concentrations ' num2str(self.options.initial_concentrations)];
            end
            
            if ~ isempty(self.options.time_step)
                options_str = [options_str ' --time_step ' int2str(self.options.time_step)];
            end
            
            
            if ~ isempty(self.options.spinup_years)
                options_str = [options_str ' --spinup_years ' int2str(self.options.spinup_years)];
            end
            
            if ~ isempty(self.options.spinup_tolerance)
                options_str = [options_str ' --spinup_tolerance ' num2str(self.options.spinup_tolerance)];
            end
            
            if ~ isempty(self.options.spinup_satisfy_years_and_tolerance) && self.options.spinup_satisfy_years_and_tolerance
                options_str = [options_str ' --spinup_satisfy_years_and_tolerance '];
            end
            
            
            if ~ isempty(self.options.derivative_accuracy_order)
                options_str = [options_str ' --derivative_accuracy_order ' int2str(self.options.derivative_accuracy_order)];
            end
            
            if ~ isempty(self.options.derivative_step_size)
                options_str = [options_str ' --derivative_step_size ' num2str(self.options.derivative_step_size)];
            end
            
            if ~ isempty(self.options.derivative_years)
                options_str = [options_str ' --derivative_years ' int2str(self.options.derivative_years)];
            end
            
            
            if ~ isempty(self.options.nodes_setup_node_kind)
                options_str = [options_str ' --nodes_setup_node_kind ' num2str(self.options.nodes_setup_node_kind)];
            end
            
            if ~ isempty(self.options.nodes_setup_number_of_nodes)
                options_str = [options_str ' --nodes_setup_number_of_nodes ' num2str(self.options.nodes_setup_number_of_nodes)];
            end
            
            if ~ isempty(self.options.nodes_setup_number_of_cpus)
                options_str = [options_str ' --nodes_setup_number_of_cpus ' num2str(self.options.nodes_setup_number_of_cpus)];
            end
            
            
            if ~ isempty(self.options.model_parameters_relative_tolerance)
                options_str = [options_str ' --model_parameters_relative_tolerance ' num2str(self.options.model_parameters_relative_tolerance)];
            end
            
            if ~ isempty(self.options.model_parameters_absolute_tolerance)
                options_str = [options_str ' --model_parameters_absolute_tolerance ' num2str(self.options.model_parameters_absolute_tolerance)];
            end
            
            if ~ isempty(self.options.initial_concentrations_relative_tolerance)
                options_str = [options_str ' --initial_concentrations_relative_tolerance ' num2str(self.options.initial_concentrations_relative_tolerance)];
            end
            
            if ~ isempty(self.options.initial_concentrations_absolute_tolerance)
                options_str = [options_str ' --initial_concentrations_absolute_tolerance ' num2str(self.options.initial_concentrations_absolute_tolerance)];
            end
            
            
            if eval_f
                options_str = [options_str ' --eval_function_value '];
            end
            if eval_df
                options_str = [options_str ' --eval_grad_value '];
            end
            
            command = [self.database_run_command ' "' options_str '"'];
        end
        
        
        function handle_error(self, code, send_mail, kill, create_error_file, wait)
        % HANDLE_ERROR is called if an error occures in the evaluation.
        %
        % Example:
        %     COST_FUNCTION.HANDLE_ERROR()
        %
        % Input:
        %     CODE: the error code
        %         type: int
        %     SEND_MAIL: Whether an notification about this error should be send by mail.
        %         type: boolean
        %     KILL: Whether this process should be killed after handling the error.
        %         type: boolean
        %     CREATE_ERROR_FILE: Whether to create a file with the error message.
        %         type: boolean
        %     WAIT: Whether to wait until the error is fixed.
        %         type: boolean
        %
        
            if code ~= 0
                error_message = ['Matlab: Error at accessing the database. Exit code: ' int2str(code) '.'];
                disp(error_message);
                if nargin >=3 & send_mail & ~ isempty(self.options.error_email_address)
                    system(['echo "An error occurred at evaluating the cost function ' self.options.cost_function_name ' for model ' self.options.model_name ' at ' self.options.exchange_dir '. The error code was ' int2str(code) '." | mail -s "Error ' int2str(code) ' at ' self.options.cost_function_name '." jor@informatik.uni-kiel.de']);
                end
                if nargin >=5 & (create_error_file | wait)
                    error_file = [self.options.exchange_dir '/' 'error.out'];
                    fid = fopen(error_file, 'w');
                    fprintf(fid, '%s\n', error_message);
                    fclose(fid);
                    if nargin >=6 & wait
                        disp(['To continue please remove ' error_file ' after the error is fixed.']);
                        while exist(error_file, 'file') == 2
                            pause(300);
                        end
                        disp(['Assume that the error is fixed and thus continue.']);
                    end
                end
                if nargin >=4 & kill
                    system(['kill ', num2str(feature('getpid'))]);
                    exit(code);
                end
            end
        end
        
        
    end
    
    methods (Access = protected, Static)
        
        function s = get_message_identifier(method, mnemonic)
        % GET_MESSAGE_IDENTIFIER returns the identifier for an error or a warning raised in methods of these object.
        %
        % Example:
        %     ID = COST_FUNCTION.GET_MESSAGE_IDENTIFIER(METHOD, MNEMONIC)
        %
        % Input:
        %     METHOD: the method in which an error or a warning occurred
        %         type: str
        %     MNEMONIC: a unique keyword for the error or warning
        %         type: str
        %
        % Output:
        %     ID: the identifier for the error or a warning
        %         type: str
        %
        
            s = ['bgc_optimization:', 'cost_function', ':', method, ':', mnemonic];
        end
        
    end
end

