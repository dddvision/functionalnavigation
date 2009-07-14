% Evaluates the optimizer object and creates an initial guess if no costs
% are provided
%
% INPUT
% m = optimizer object
% s = (optional) cost object
%
% OUTPUT
% v = array of dynamic noise bit vectors, vbits-by-popsize
% w = array of static noise bit vectors, wbits-by-popsize


function [v,w]=eval(m,s)
if( nargin>1 )
  v=[];
  w=[];
else
  v=logical(rand(m.vbits,m.popsize)>=0.5);
  w=logical(rand(m.wbits,m.popsize)>=0.5);
end
return;
