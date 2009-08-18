% Generates a new population using the Matlab GADS toolbox
%
% INPUT/OUTPUT
% v = dynamic seed, vsize-by-popsize
% w = static seed, wsize-by-popsize
% c = costs, 1-by-popsize
%
% NOTE
% Requires a license for the Matlab GADS toolbox

function [v,w]=gauncstep(this,v,w,c)

vsize=size(v,1);
popsize=size(v,2);
vw=double([v',w']);
c=c';

options=this.defaultOptions;
options.PopulationSize=popsize;
options.EliteCount=max(1,popsize/20);

nvars = size(vw,2);
nullstate=struct('FunEval',0);
nullobjective=@(x) zeros(size(x,1),1);
[unused,vw]=feval(this.stepGAhandle,c,vw,options,nullstate,nvars,nullobjective);

v=vw(:,1:vsize)';
w=vw(:,(vsize+1):end)';

end
