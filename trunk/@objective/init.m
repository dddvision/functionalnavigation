% Provides a set of initial points in the domain of the objective
%
% INPUT
% this = objective object
%
% OUTPUT
% v = array of dynamic noise bit vectors, vbits-by-popsize
% w = array of static noise bit vectors, wbits-by-popsize
  

function [v,w]=init(this)
  v=logical(rand(this.vbits,this.popsize)>=0.5);
  w=logical(rand(this.wbits,this.popsize)>=0.5);
end