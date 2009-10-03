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
    
    function [this,initialCost]=defineProblem(this,objectiveFunction,initialParameters)
      initialCost=feval(objectiveFunction,initialParameters);
      this.objective=objectiveFunction;
      this.parameters=initialParameters;
      this.cost=initialCost;
    end
    
    function [this,parameters,cost]=step(this)
      cost=feval(this.objective,this.parameters);
      parameters=this.parameters;
      this.cost=cost;
      % TODO: keep the best and randomize the rest
    end
  end
  
end
