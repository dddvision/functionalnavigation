function [this,initialCost]=defineProblem(this,objectiveFunction,initialParameters)
  initialCost=feval(objectiveFunction,initialParameters);
  this.objective=objectiveFunction;
  this.parameters=initialParameters;
  this.cost=initialCost;
end
