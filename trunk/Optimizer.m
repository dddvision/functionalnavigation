% This class defines the interface to an optimization engine
classdef Optimizer < handle

  methods (Static=true,Access=public)
    % Framework class identifier
    %
    % OUTPUT
    % text = name of the framework class, string
    function text=frameworkClass
      text='Optimizer';
    end
      
    % Public method to construct an Optimizer
    %
    % INPUT
    % pkg = package identifier, string
    % (see constructor argument list)
    %
    % OUTPUT
    % obj = object instance, Optimizer scalar
    %
    % NOTES
    % Do not shadow this function
    % The package directory must in the environment path
    % (MATLAB) Omit the '+' prefix when identifying package names
    function obj=factory(pkg,dynamicModelName,measureNames,uri)
      subclass=[pkg,'.',pkg];
      if(exist(subclass,'class'))
        obj=feval(subclass,dynamicModelName,measureNames,uri);
      else
        obj=OptimizerBridge(pkg,dynamicModelName,measureNames,uri);
      end
      assert(isa(obj,'Optimizer'));
    end
  end
  
  methods (Access=protected)
    % Protected method to construct an Optimizer
    %
    % INPUT
    % dynamicModelName = name of a DynamicModel subclass, string
    % measureNames = list of names of Measure subclasses, cell array of strings
    % uri = (see Measure constructor)
    %
    % NOTES
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@Optimizer(dynamicModelName,measureNames,uri);
    function this=Optimizer(dynamicModelName,measureNames,uri)
      assert(isa(dynamicModelName,'char'));
      assert(isa(measureNames,'cell'));
      assert(isa(measureNames{1},'char'));
      assert(isa(uri,'char'));
    end
  end
  
  methods (Abstract=true)
    % Get the number of results
    %
    % OUTPUT
    % num = number of results, uint32 scalar
    num=numResults(this);
    
    % Get the most recent trajectory estimate
    %
    % INPUT
    % k = zero based result index, uint32 scalar
    %
    % OUTPUT
    % xEst = trajectory instance, Trajectory scalar
    %
    % NOTES
    % This function returns initial conditions if called before the first optimization step occurrs
    % Throws an exception if index is out of range
    xEst=getTrajectory(this,k);
    
    % Get the most recent cost estimate
    %
    % INPUT
    % k = zero based result index, uint32 scalar
    %
    % OUTPUT
    % cEst = non-negative cost associated with each trajectory instance, double scalar
    %
    % NOTES
    % This function returns initial conditions if called before the first optimization step occurrs
    % Throws an exception if index is out of range
    cEst=getCost(this,k);
    
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
