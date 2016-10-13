classdef cost_function_scalable < cost_function & handle
% COST_FUNCTION_SCALABLE represents the cost function with parameters scaled to [-1, 1] and an scaling factor fo the cost function output values.
%
% COST_FUNCTION_SCALABLE Methods:
%     COST_FUNCTION_SCALABLE - creates a COST_FUNCTION_SCALABLE object.
%     EVAL - evaluates the cost function.
%
%   Copyright (C) 2011-2016 Joscha Reimer jor@informatik.uni-kiel.de
    
    properties (Access = public)
        p_lb;
        p_ub;
        f_scaling_factor = 1;
    end
    
    methods (Access = public)
        
        function self = cost_function_scalable(options, p_lb, p_ub)
        % COST_FUNCTION_SCALABLE creates a COST_FUNCTION_SCALABLE object.
        %
        % Example:
        %     OBJ = COST_FUNCTION_SCALABLE(OPTIONS)
        %
        % Input:
        %     OPTIONS: The options used for the cost function evaluations.
        %         type: cost_function_options
        %
        % Output:
        %     OBJ: a COST_FUNCTION_SCALABLE object with the passed configurations
        %
        % see also COST_FUNCTION_SCALABLE_OPTIONS
        %
            
            % call cost_function constructor
            self@cost_function(options);    
            
            % set p_lb and p_ub
            self.p_lb = p_lb;
            self.p_ub = p_ub;
            
        end
        
        
        function ps = p_scale(self, p)
            ps = (2 * p  - (self.p_ub + self.p_lb)) ./ (self.p_ub - self.p_lb);
        end
        
        function p = p_unscale(self, ps)
            p = (ps .* (self.p_ub - self.p_lb) + (self.p_ub + self.p_lb)) / 2;
        end
        
        function fs = f_scale(self, f)
            fs = f * self.f_scaling_factor;
        end
        
        function f = f_unscale(self, fs)
            f = fs / self.f_scaling_factor;
        end
        
        function dfs = df_scale(self, df)
            dfs = df .* (self.p_ub - self.p_lb)' / 2 * self.f_scaling_factor;
        end
        
        function df = df_unscale(self, dfs)
            df = dfs ./ (self.p_ub - self.p_lb)' * 2 / self.f_scaling_factor;
        end
        
        
        function [fs, dfs] = eval(self, ps)
        % EVAL evaluates the scaled cost function.
        %
        % Example:
        %     FS = COST_FUNCTION_SCALABLE_OBJECT.EVAL(PS)
        %     or
        %     [FS, DFS] = COST_FUNCTION_SCALABLE_OBJECT.EVAL(PS)
        %
        % Input:
        %     PS: The scaled parameters where to evaluate the cost function.
        %         type: float vector (of len n)
        %
        % Output:
        %     F: the scaled value of the cost function 
        %         type: float
        %     DF: the scaled value of the derivative of the cost function 
        %         type: float vector (of len n)
        %
        
            
            p = self.p_unscale(ps);
            if nargout == 2
                [f, df] = eval@cost_function(self, p);
            else
                [f] = eval@cost_function(self, p);
            end
            fs = self.f_scale(f);
            if nargout == 2
                dfs = self.df_scale(df);
            end
        end
        
    end
    
end

