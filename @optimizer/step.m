% Execute one step of the optimizer


function [m,H,v,w]=step(m,H,v,w)
[H,c]=evaluate(H,v,w);
return;
