classdef cost_function < handle
% COST_FUNCTION represents the cost function.
%
% COST_FUNCTION Methods:
%     COST_FUNCTION - creates a COST_FUNCTION object.
%     EVAL - evaluates the cost function.
%
%   Copyright (C) 2011-2015 Joscha Reimer jor@informatik.uni-kiel.de
    
    properties (Access = protected)
        options;
    end
    
    properties (Constant)
        parameter_filename = 'p.mat';
        f_filename = 'f.mat';
        df_filename = 'df.mat';
        output_filename = 'out.txt';

        database_run_command = '/sfs/fs3/work-sh1/sunip229/database/access';
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
            fid = fopen([self.options.exchange_dir '/' 'run.sh'], 'w');
            fprintf(fid, '%s\n', command);
            fclose(fid);
            
            %% execute access command
            status = system(command);
            if status ~= 0
                self.handle_error(status);
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
        % Output:
        %     COMMAND: the database access command
        %         type: str
        %
        
            options_str = '';
            options_str = [options_str ' --kind_of_cost_function ' self.options.cost_function_kind];
            options_str = [options_str ' --exchange_dir ' self.options.exchange_dir];
            options_str = [options_str ' --debug_logging_file ' self.options.exchange_dir '/' self.output_filename];
            
            if eval_f
                options_str = [options_str ' --eval_function_value '];
            end
            if eval_df
                options_str = [options_str ' --eval_grad_value '];
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
            
            if ~ isempty(self.options.nodes_setup_node_kind)
                options_str = [options_str ' --nodes_setup_node_kind ' num2str(self.options.nodes_setup_node_kind)];
            end
            
            if ~ isempty(self.options.nodes_setup_number_of_nodes)
                options_str = [options_str ' --nodes_setup_number_of_nodes ' num2str(self.options.nodes_setup_number_of_nodes)];
            end
            
            if ~ isempty(self.options.nodes_setup_number_of_cpus)
                options_str = [options_str ' --nodes_setup_number_of_cpus ' num2str(self.options.nodes_setup_number_of_cpus)];
            end
            
            if ~ isempty(self.options.parameters_relative_tolerance)
                options_str = [options_str ' --parameters_relative_tolerance ' num2str(self.options.parameters_relative_tolerance)];
            end
            
            if ~ isempty(self.options.parameters_absolute_tolerance)
                options_str = [options_str ' --parameters_absolute_tolerance ' num2str(self.options.parameters_absolute_tolerance)];
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
            
            command = [self.database_run_command ' "' options_str '"'];
        end
        
        
        function handle_error(self, code)
        % HANDLE_ERROR is called if an error occures in the evaluation.
        %
        % Example:
        %     COST_FUNCTION.HANDLE_ERROR()
        %
        % Input:
        %     CODE: the error code
        %         type: int
        %
        
            disp(['Matlab: Error at accessing the database. Exit code: ' int2str(code) '.']);
            if ~ isempty(self.options.error_email_address)
                system(['echo "An error occurred at evaluating the cost function ' self.options.cost_function_kind ' at ' self.options.exchange_dir '. The error code was ' int2str(code) '." | mail -s "Error at evaluating the cost function ' self.options.cost_function_kind '." jor@informatik.uni-kiel.de']);
            end
            system(['kill ', num2str(feature('getpid'))]);
            exit(status);
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
        
            s = ['ndop_evaluation_toolbox:', 'cost_function', ':', method, ':', mnemonic];
        end
        
    end
end

