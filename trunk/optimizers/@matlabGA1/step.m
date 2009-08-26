% Requires a license for the Matlab GADS toolbox
function [this,parameters,cost]=step(this)

% TODO: move these lines to matlabGA1::defineProblem ?
[popsize,nvars]=size(this.parameters);
options=this.defaultOptions;
options.PopulationSize=popsize;
options.EliteCount=max(1,popsize/20);
nullstate=struct('FunEval',0);
%nullobjective=@(x) zeros(size(x,1),1);

[cost,parameters]=feval(this.stepGAhandle,this.cost,this.parameters,options,nullstate,nvars,this.objective);
this.parameters=parameters;
this.cost=cost;

end
