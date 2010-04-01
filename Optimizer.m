% This class defines the interface to an optimization engine
classdef Optimizer < handle
  
  properties (Constant=true,GetAccess=public)
    frameworkClass='Optimizer';  
  end

  methods (Static=true,Access=public)
    % Instantiate a subclass by name
    %
    % INPUT
    % pkg = package identifier, string
    %
    % OUTPUT
    % obj = object instance, Optimizer scalar
    %
    % NOTES
    % The package directory must in the environment path
    % (MATLAB) Omit the '+' prefix when identifying package names
    function obj=factory(pkg)
      obj=feval([pkg,'.',pkg]);
      assert(isa(obj,'Optimizer'));
    end
  end
  
  methods (Abstract=true)
    % Get the most recent trajectory and cost estimates
    %
    % OUTPUT
    % xEst = trajectory instances, popSize-by-1
    % cEst = non-negative cost associated with each trajectory instance, double popSize-by-1
    %
    % NOTES
    % This function returns initial conditions if called before the first optimization step occurrs
    [xEst,cEst]=getResults(this);
    
    % Execute one step of the optimizer to evolve parameters toward lower cost
    %
    % NOTES
    % This function refreshes the objective and determines the current 
    %   number of input parameter blocks and output costs
    % The optimizer may learn about the objective function over multiple
    %   calls by maintaining state using class properties
    % This function may evaluate the objective multiple times, though a
    %   single evaluation per step is preferred
    step(this);
  end
  
end
