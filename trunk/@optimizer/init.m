% Provides an initial guess output from the optimizer object
%
% INPUT
% m = optimizer object
%
% OUTPUT
% v = array of dynamic noise bit vectors, vbits-by-popsize
% w = array of static noise bit vectors, wbits-by-popsize


function [v,w]=init(m)
v=logical(rand(m.vbits,m.popsize)>=0.5);
w=logical(rand(m.wbits,m.popsize)>=0.5);
return;
