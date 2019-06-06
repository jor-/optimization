classdef cost_function_options < handle
% COST_FUNCTION_OPTIONS represents the options for the cost function.
%
% COST_FUNCTION_OPTIONS Methods:
%     COST_FUNCTION_OPTIONS - creates a COST_FUNCTION_OPTIONS object.
%     SET_OPTION - changes an option.
%     GET_OPTION - returns the value of an option.
%
%   Copyright (C) 2011-2019 Joscha Reimer jor@informatik.uni-kiel.de
    
    properties (Access = public)
        cost_function_name
        model_name
        
        exchange_dir
        
        max_box_distance_to_water
        min_standard_deviations
        min_measurements_standard_deviations
        min_measurements_correlations
        
        initial_concentrations
        time_step
        
        spinup_years
        spinup_tolerance
        spinup_satisfy_years_and_tolerance
        
        derivative_accuracy_order
        derivative_step_size
        derivative_years
        
        nodes_setup_node_kind
        nodes_setup_number_of_nodes
        nodes_setup_number_of_cpus
        
        model_parameters_absolute_tolerance
        model_parameters_relative_tolerance
        initial_concentrations_absolute_tolerance
        initial_concentrations_relative_tolerance
        
        error_email_address
    end
    
    
    methods (Access = public)
        
        function self = cost_function_options(varargin)
        % COST_FUNCTION_OPTIONS creates a COST_FUNCTION_OPTIONS object.
        %
        % Example:
        %     OBJ = COST_FUNCTION_OPTIONS('OPTION1',VALUE1,'OPTION2',VALUE2,...)
        %
        % Input:
        %     'cost_function_name': The cost function which should be evaluated.
        %         type: str
        %     'model_name': The name of the model to use.
        %         type: str
        %     'exchange_dir': The directory from where to load the parameters and where to save the cost function values.
        %         type: str
        %     'max_box_distance_to_water': The maximal allowed box distance to water used to determine valid measurements.
        %         type: int (non-negative)
        %         optional: All measurements are used if empty.
        %     'min_standard_deviations': The minimal standard deviations assumed for the measurement errors.
        %         type: float vector (non-negative)
        %         optional: Default value used if empty.
        %     'min_measurements_standard_deviations': The numbers of minimal measurements used to calculate standard_deviations.
        %         type: int vector (non-negative)
        %         optional: Default value used if empty.
        %     'min_measurements_correlations': The numbers of minimal measurements used to calculate correlations.
        %         type: int vector (non-negative)
        %         optional: Default value used if empty.
        %     'initial_concentrations': The initial concentrations to use for the model spinup.
        %         type: float vector (non-negative)
        %         optional: Default value used if empty.
        %     'time_step': The time step size to use in the model.
        %         type: int (positive)
        %         optional: Default value used if empty. default value: 1
        %     'spinup_years': The number of years for the spinup.
        %         type: int (positive)
        %         optional: Default value used if empty. default value: 10000
        %     'spinup_tolerance': The tolerance for the spinup.
        %         type: float (non-negative)
        %         optional: Default value used if empty. default value: decimal resolution of float type
        %     'spinup_satisfy_years_and_tolerance': If used, the spinup is terminated if years and tolerance have been satisfied. Otherwise, the spinup is terminated as soon as years or tolerance have been satisfied.
        %         type: boolean
        %         optional: Default value used if empty. default value: False
        %     'derivative_accuracy_order': The accuracy order used for the finite difference approximation. 1 = forward differences. 2 = central differences.
        %         type: int (positive)
        %         optional: Default value used if empty. default value: 2
        %     'derivative_step_size': The step size used for the finite difference approximation.
        %         type: float (positive)
        %         optional: Default value used if empty. default value: 10^(-7)
        %     'derivative_years': The number of years for the finite difference approximation spinup.
        %         type: int (positive)
        %         optional: Default value used if empty. default value: 100
        %     'nodes_setup_node_kind': The node kind to use for the spinup.
        %         type: str
        %     'nodes_setup_number_of_nodes': The number of nodes to use for the spinup.
        %         type: int (positive)
        %     'nodes_setup_number_of_cpus': The number of cpus to use for the spinup.
        %         type: int (positive)
        %     'model_parameters_absolute_tolerance': The absolute tolerance from which two parameter vectors are treated as equal.
        %         type: float vector (non-negative) (of len n or len 1)
        %         optional: Default value used if empty. default value: decimal resolution of float type
        %     'model_parameters_relative_tolerance': The relative tolerance from which two parameter vectors are treated as equal.
        %         type: float vector (non-negative) (of len n or len 1)
        %         optional: Default value used if empty. default value: 0
        %     'initial_concentrations_absolute_tolerance': The absolute tolerance from which two parameter vectors are treated as equal.
        %         type: float vector (non-negative) (of len n or len 1)
        %         optional: Default value used if empty. default value: decimal resolution of float type
        %     'initial_concentrations_relative_tolerance': The relative tolerance from which two parameter vectors are treated as equal.
        %         type: float vector (non-negative) (of len n or len 1)
        %         optional: Default value used if empty. default value: 0
        %     'error_email_address': The email address where to write a mail if an error occurred.
        %         type: string
        %         optional: No mail is written if empty.
        %
        % Output:
        %     OBJ: a COST_FUNCTION_OPTIONS object with the passed configurations
        %
        % Throws:
        %     An error if a value doesn't match to an option or a wrong
        %     option is passed.
        %
            
            % set default options

            absolute_resolution = 10^ceil(log(eps)/log(10))
            
            self.max_box_distance_to_water = [];
            self.min_standard_deviations = [];
            self.min_measurements_standard_deviations = [];
            self.min_measurements_correlations = [];
            
            self.initial_concentrations = [];
            self.time_step = 1;
            
            self.spinup_years = 10000;
            self.spinup_tolerance = absolute_resolution;
            self.spinup_satisfy_years_and_tolerance = 0;
            
            self.derivative_accuracy_order = 2;
            self.derivative_step_size = 10^(-7);
            self.derivative_years = 100;
            
            self.nodes_setup_node_kind = [];
            self.nodes_setup_number_of_nodes = [];
            self.nodes_setup_number_of_cpus = [];
            
            self.model_parameters_absolute_tolerance = absolute_resolution;
            self.model_parameters_relative_tolerance = 0;
            self.initial_concentrations_absolute_tolerance = absolute_resolution;
            self.initial_concentrations_relative_tolerance = 0;
            
            self.error_email_address = [];
            
            % insert passed options
            if mod(nargin, 2) == 0
                for i=1:2:nargin
                    self.set_option(varargin{i}, varargin{i+1});
                end
            else
                error(self.get_message_identifier('cost_function_options', 'wrong_number_of_arguments'), 'The number of input arguments is odd. Please check the input arguments.');
            end            
            
        end
        
        
        
        function set_option(self, name, value)
        % SET_OPTION changes an option.
        %
        % Example:
        %     COST_FUNCTION_OPTIONS_OBJECT.SET_OPTION(NAME, VALUE)
        %
        % Input:
        %     NAME: the name of the option to be changed
        %         type: str
        %     VALUE: the new value of the option
        %         type: depending on the option
        %
        % Throws:
        %     An error if a value doesn't match to an option or a wrong
        %     option is passed.
        %
        % see also COST_FUNCTION_OPTIONS.COST_FUNCTION_OPTIONS
        %
            
            % check option name
            if ~ ischar(name)
                error(self.get_message_identifier('set_option', 'name_no_string'), 'The optione name has to be a string.');
            end
            
            % update option
            self.(name) = value;            
        end
        
        
        
        function option = get_option(self, name)
        % GET_OPTION returns the value of an option.
        %
        % Example:
        %     COST_FUNCTION_OPTIONS_OBJECT.GET_OPTION(NAME)
        %
        % Input:
        %     NAME: the name of the option which value will be returned
        %         type: str
        %
        % Output:
        %     VALUE: the value of the passed option
        %         type: depending on the option
        %
        % Throws:
        %     An error if the option doesn't exist.
        %
        % see also COST_FUNCTION_OPTIONS.COST_FUNCTION_OPTIONS, SET_OPTION
        %
        
            try
                option = self.(name);
            catch exception
                error(self.get_message_identifier('get_option', 'unknown_option_name'), ['The option "', name, '" is not supported.']);  
            end
        end
        
    end
    
    
    methods
    
        function self = set.cost_function_name(self, value)
            if ~ (isstr(value))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for cost_function_name has to be a string.']);
            end
            self.cost_function_name = value;
        end
    
        function self = set.model_name(self, value)
            if ~ (isstr(value))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for model_name has to be a string.']);
            end
            self.model_name = value;
        end
        
    
        function self = set.exchange_dir(self, value)
            if ~ (isstr(value))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for exchange_dir has to be a string.']);
            end
            self.exchange_dir = value;
        end
        
    
        function self = set.max_box_distance_to_water(self, value)
            if ~ isempty(value)
                if ischar(value)
                    value = str2num(value);
                end
                if ~ (isnumeric(value) && isscalar(value) && value == fix(value) && value >= 0)
                    error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for max_box_distance_to_water has to be a non-negative scalar integer or be empty.']);
                end
            end
            self.max_box_distance_to_water = value;
        end

        function self = set.min_standard_deviations(self, value)
            if ~ isempty(value)
                if ischar(value)
                    value = str2num(value);
                end
                if ~ (isnumeric(value) && all(value >= 0))
                    error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for min_standard_deviations has to be a row vector with non-negative entries or be empty.']);
                end
            end
            self.min_standard_deviations = value;
        end
    
        function self = set.min_measurements_standard_deviations(self, value)
            if ~ isempty(value)
                if ischar(value)
                    value = str2num(value);
                end
                if ~ (isempty(value) || (isnumeric(value) && value == fix(value) && all(value > 0)))
                    error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for min_measurements_standard_deviations has to be a row vector with non-negative entries or be empty.']);
                end
            end
            self.min_measurements_standard_deviations = value;
        end
    
        function self = set.min_measurements_correlations(self, value)
            if ~ isempty(value)
                if ischar(value)
                    value = str2num(value);
                end
                if ~ (isempty(value) || (isnumeric(value) && value == fix(value) && all(value > 0)))
                    error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for min_measurements_correlations has to be a row vector with non-negative entries or be empty.']);
                end
            end
            self.min_measurements_correlations = value;
        end
        
    
        function self = set.initial_concentrations(self, value)
            if ~ (isempty(value) || (isnumeric(value) && all(value >= 0)))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for initial_concentrations has to be a row vector with non-negative entries or be empty.']);
            end
            self.initial_concentrations = value;
        end
    
        function self = set.time_step(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value == fix(value) && value > 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for time_step has to be a positive scalar integer or be empty.']);
            end
            self.time_step = value;
        end
        
    
        function self = set.spinup_years(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value == fix(value) && value >= 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for spinup_years has to be a positive scalar integer or be empty.']);
            end
            self.spinup_years = value;
        end
    
        function self = set.spinup_tolerance(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value >= 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for spinup_tolerance has to be a positive scalar or be empty.']);
            end
            self.spinup_tolerance = value;
        end
        
        function self = set.spinup_satisfy_years_and_tolerance(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && any(value == [0, 1])))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for spinup_satisfy_years_and_tolerance has to be 0 or 1.']);
            end
            self.spinup_satisfy_years_and_tolerance = value;
        end
    
    
        function self = set.derivative_accuracy_order(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && any(value == [1, 2])))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for derivative_accuracy_order has to be 1 or 2.']);
            end
            self.derivative_accuracy_order = value;
        end
    
        function self = set.derivative_step_size(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value > 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for derivative_step_size has to be a positive scalar or be empty.']);
            end
            self.derivative_step_size = value;
        end
        
        function self = set.derivative_years(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value == fix(value) && value >= 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for derivative_years has to be a positive scalar integer or be empty.']);
            end
            self.derivative_years = value;
        end
        
    
        function self = set.nodes_setup_node_kind(self, value)
            if ~ (isempty(value) || isstr(value))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for nodes_setup_node_kind has to be a string or be empty.']);
            end
            self.nodes_setup_node_kind = value;
        end
    
        function self = set.nodes_setup_number_of_nodes(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value == fix(value) && value > 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for nodes_setup_number_of_nodes has to be a positive scalar integer or be empty.']);
            end
            self.nodes_setup_number_of_nodes = value;
        end
        
        function self = set.nodes_setup_number_of_cpus(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value == fix(value) && value > 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for nodes_setup_number_of_cpus has to be a positive scalar integer or be empty.']);
            end
            self.nodes_setup_number_of_cpus = value;
        end
        
    
        function self = set.model_parameters_absolute_tolerance(self, value)
            if ~ (isempty(value) || (isnumeric(value) && all(value >= 0)))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for model_parameters_absolute_tolerance has to be a positive scalar or a row vector with non-negative entries or be empty.']);
            end
            self.model_parameters_absolute_tolerance = value;
        end
        
        function self = set.model_parameters_relative_tolerance(self, value)
            if ~ (isempty(value) || (isnumeric(value) && all(value >= 0)))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for model_parameters_relative_tolerance has to be a positive scalar or a row vector with non-negative entries or be empty.']);
            end
            self.model_parameters_relative_tolerance = value;
        end
        
    
        function self = set.initial_concentrations_absolute_tolerance(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value >= 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for initial_concentrations_absolute_tolerance has to be a positive scalar or be empty.']);
            end
            self.initial_concentrations_absolute_tolerance = value;
        end
        
        function self = set.initial_concentrations_relative_tolerance(self, value)
            if ~ (isempty(value) || (isnumeric(value) && isscalar(value) && value >= 0))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for initial_concentrations_relative_tolerance has to be a positive scalar or be empty.']);
            end
            self.initial_concentrations_relative_tolerance = value;
        end
        
    
        function self = set.error_email_address(self, value)
            if ~ (isempty(value) || isstr(value))
                error(self.get_message_identifier('set_option', 'wrong_value'), ['The value for error_email_address has to be a string or be empty.']);
            end
            self.error_email_address = value;
        end
            
        
    end
    
    
    methods (Access = protected, Static)
        
        function s = get_message_identifier(method, mnemonic)
        % GET_MESSAGE_IDENTIFIER returns the identifier for an error or a warning raised in methods of these object.
        %
        % Example:
        %     ID = COST_FUNCTION_OPTIONS.GET_MESSAGE_IDENTIFIER(METHOD, MNEMONIC)
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
        
            s = ['bgc_optimization:', 'cost_function_options', ':', method, ':', mnemonic];
        end
        
    end
end

