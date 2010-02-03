% This class defines the interface to an optimization engine
classdef optimizer < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='optimizer';  
  end
  
  methods (Abstract=true)
    % Define a minimization problem
    %
    % INPUT
    % dynamicModelName = name of a dynamicModel object, string
    % measureNames = list of names of measure objects, cell array of strings
    % dataURI = see measure class constructor
    %
    % OUTPUT
    % initialCost = cost associated with initial parameters, double popsize-by-1
    % 
    % NOTES
    % This operation creates a single dynamic model and multiple measures
    initialCost=defineProblem(this,dynamicModelName,measureNames,dataURI);
    
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
    
    % Get the most recent trajectory and cost estimates
    %
    % OUTPUT
    % xEst = trajectory instances, popSize-by-1
    % cEst = non-negative cost associated with each trajectory instance, double popSize-by-1
    [xEst,cEst]=getResults(this);
  end
  
end
