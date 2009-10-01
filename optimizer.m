classdef optimizer
  
  methods (Abstract=true)
    % Define a minimization problem
    %
    % INPUT
    % objectiveFunction = function handle of vectorized objective
    % initialParameters = initial parameters in the domain of the objective, logical popsize-by-nvars
    %
    % OUTPUT
    % initialCost = cost associated with initialParameters, double popsize-by-1
    [this,initialCost]=defineProblem(this,objectiveFunction,initialParameters);
    
    % Execute one step of the optimizer to evolve seeds toward lower cost
    %
    % OUTPUT
    % parameters = parameters in the domain of the objective, logical popsize-by-nvars
    % cost = cost associated with parameters, double popsize-by-1
    %
    % NOTES
    % The optimizer may learn about the objective function over multiple
    % calls by maintaining state using class properties.
    % This function may evaluate the objective multiple times, though a
    % single evaluation per step is preferred.
    [this,parameters,cost]=step(this);
  end
  
end
