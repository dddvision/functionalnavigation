% Provides a set of initial points in the domain of the objective
%
% INPUT
% H = objective object
%
% OUTPUT
% v = array of dynamic noise bit vectors, vbits-by-popsize
% w = array of static noise bit vectors, wbits-by-popsize


function [v,w]=init(H)
v=logical(rand(H.vbits,H.popsize)>=0.5);
w=logical(rand(H.wbits,H.popsize)>=0.5);
end
