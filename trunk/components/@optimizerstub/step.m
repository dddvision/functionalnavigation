% Execute one step of the optimizer
%
% INPUT/OUTPUT
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
% This function can modify the object state.


function [this,H,v,w]=step(this,H,v,w)
[H,c]=evaluate(H,v,w);
fprintf('\n');
fprintf('\ncost summary:');
fprintf('\n%f',c);
fprintf('\n');
end
