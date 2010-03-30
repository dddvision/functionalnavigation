% This class defines the interface to an optimization engine
classdef Optimizer < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='Optimizer';  
  end

  methods (Static=true,Access=public)
    % Instantiate a subclass by name
    %
    % INPUT
    % pkg = package identifier, string
    % (see constructor argument list)
    %
    % OUTPUT
    % obj = object instance, Optimizer scalar
    %
    % NOTES
    % The package directory must in the environment path
    % (MATLAB) Omit the '+' prefix when identifying package names
    function obj=factory(pkg,dynamicModelName,measureNames,uri)
      obj=feval([pkg,'.',pkg],dynamicModelName,measureNames,uri);
      assert(isa(obj,'Optimizer'));
    end
  end
  
  methods (Access=protected)
    % Construct an optimizer that varies dynamic model parameters to minimize costs
    %
    % INPUT
    % dynamicModelName = name of a DynamicModel subclass, string
    % measureNames = list of names of Measure subclasses, cell array of strings
    % uri = (see Measure class constructor)
    % 
    % NOTES
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@Optimizer(dynamicModelName,measureNames,uri);
    function this=Optimizer(dynamicModelName,measureNames,uri)
      assert(isa(dynamicModelName,'char'));
      assert(isa(measureNames,'cell'));      
      assert(isa(uri,'char'));
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
