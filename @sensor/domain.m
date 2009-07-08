% Return the first and last indices of sensor data
%
% INPUT
% g = sensor object
%
% OUTPUT
% a = integer index of first data element
% b = integer index of last data element


function [a,b]=domain(g)

a=g.index(1);
b=g.index(end);

return;
