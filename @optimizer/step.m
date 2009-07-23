% Execute one step of the optimizer
%
% INPUT/OUTPUT
% M = optimizer object
% H = objective object
% v = dynamic seed, M-by-popsize
% w = static seed, N-by-popsize
%
% NOTES
% The primary purpose of this function is to evolve better seeds {v,w}
% by implicitly calling the evaluate() function of the objective object.
%
% H = The objective object is passed through eval() but
% is otherwise unmodified by step().
%
% This function may modify the state of its first arg.


function [M,H,v,w]=step(M,H,v,w)
[H,c]=evaluate(H,v,w);
fprintf('\ncost:\n');
disp(c');
return;
