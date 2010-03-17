% This class defines the interface to an optimization engine
classdef optimizer < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='optimizer';  
  end

  methods (Access=protected)
    % Construct an optimizer that varies dynamic model parameters to minimize costs
    %
    % INPUT
    % dynamicModelName = name of a dynamicModel object, string
    % measureNames = list of names of measure objects, cell array of strings
    % dataURI = see measure class constructor
    % 
    % NOTES
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@optimizer(dynamicModelName,measureNames,dataURI);
    function this=optimizer(dynamicModelName,measureNames,dataURI)
      assert(isa(dynamicModelName,'char'));
      assert(isa(measureNames,'cell'));      
      assert(isa(dataURI,'char'));
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
