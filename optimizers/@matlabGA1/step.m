% Requires a license for the Matlab GADS toolbox
function [this,bits,cost]=step(this,fun,bits)

[popsize,nvars]=size(bits);

options=this.defaultOptions;
options.PopulationSize=popsize;
options.EliteCount=max(1,popsize/20);

cost=feval(fun,bits);

nullstate=struct('FunEval',0);
nullobjective=@(x) zeros(size(x,1),1);
[unused,bits]=feval(this.stepGAhandle,cost,bits,options,nullstate,nvars,nullobjective);

end
