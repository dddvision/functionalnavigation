% Generates a new population using the Matlab GADS toolbox
%
% INPUT/OUTPUT
% v = trajectory seed, vsize-by-popsize
% w = sensor seed, wsize-by-popsize
% c = costs, 1-by-popsize
%
% NOTE
% Requires a license for the Matlab GADS toolbox


function [this,v,w]=step(this,v,w,c)

vsize=size(v,2);
vw=double([v,w]); % TODO: check whether conversion to double is necessary

[popsize,nvars]=size(vw);

options=this.defaultOptions;
options.PopulationSize=popsize;
options.EliteCount=max(1,popsize/20);

nullstate=struct('FunEval',0);
nullobjective=@(x) zeros(size(x,1),1);
[unused,vw]=feval(this.stepGAhandle,c,vw,options,nullstate,nvars,nullobjective);

v=vw(:,1:vsize);
w=vw(:,(vsize+1):end);

end
