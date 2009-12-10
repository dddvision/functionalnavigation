classdef optimizerStub < optimizer
  
  properties (GetAccess=private,SetAccess=private)
    objective
    parameters
    cost
  end
  
  methods (Access=public)
    function this=optimizerStub
      fprintf('\n');
      fprintf('\noptimizerStub::optimizerStub');
    end
    
    function initialCost=defineProblem(this,objectiveFunction,initialParameters)
      initialCost=feval(objectiveFunction,initialParameters);
      this.objective=objectiveFunction;
      this.parameters=initialParameters;
      this.cost=initialCost;
    end
    
    % Sorts the parameter sets by their cost
    % Does not evolve them toward lower cost
    function [parameters,cost]=step(this)
      parameters=this.parameters;
      cost=feval(this.objective,parameters);
      [cost,index]=sort(cost);
      parameters=parameters(index,:);
      this.cost=cost;
    end
  end
  
end
