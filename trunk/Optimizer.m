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
    function obj=factory(pkg,dynamicModel,measure)
      subclass=[pkg,'.',pkg];
      if(exist(subclass,'class'))
        obj=feval(subclass,dynamicModel,measure);
      else
        obj=OptimizerBridge(pkg,dynamicModel,measure);
      end
      assert(isa(obj,'Optimizer'));
    end
  end
  
  methods (Access=protected)
    % Protected method to construct an Optimizer
    %
    % INPUT
    % dynamicModel = multiple instances of a single DynamicModel subclass, DynamicModel K-by-1
    % measure = multiple instances of different Measure subclasses, cell M-by-1
    %
    % NOTES
    % No assumptions should be made about the initial state of the input objects
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@Optimizer(dynamicModel,measure);
    function this=Optimizer(dynamicModel,measure)
      assert(isa(dynamicModel,'DynamicModel'));
      assert(isa(measure,'cell'));
      for m=1:numel(measure)
        assert(isa(measure{m},'Measure'));
      end
    end
  end
  
  methods (Abstract=true)
    % Get the number of results
    %
    % OUTPUT
    % num = number of results, uint32 scalar
    num=numResults(this);
    
    % Get the most recent trajectory estimate in the form of a dynamic model
    %
    % INPUT
    % k = zero based result index, uint32 scalar
    %
    % OUTPUT
    % xEst = trajectory instance in the form of a dynamic model, DynamicModel scalar
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
