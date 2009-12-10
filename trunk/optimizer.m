% This class defines the interface to an optimization engine
classdef optimizer < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='optimizer';  
  end
  
  methods (Abstract=true)
    % Define a minimization problem
    %
    % INPUT
    % objectiveFunction = function handle of vectorized objective
    % initialParameters = initial parameters in the domain of the objective, cell array popsize-by-1
    %
    % OUTPUT
    % initialCost = cost associated with initialParameters, double popsize-by-1
    % 
    % NOTES
    % This operation affects state
    initialCost=defineProblem(this,objectiveFunction,initialParameters);
    
    % Execute one step of the optimizer to evolve parameters toward lower cost
    %
    % OUTPUT
    % parameters = parameters in the domain of the objective, cell array popsize-by-1
    % cost = cost associated with parameters, double popsize-by-1
    %
    % NOTES
    % The optimizer may learn about the objective function over multiple
    %   calls by maintaining state using class properties.
    % This function may evaluate the objective multiple times, though a
    %   single evaluation per step is preferred.
    % This operation affects state
    [parameters,cost]=step(this);
  end
  
end
