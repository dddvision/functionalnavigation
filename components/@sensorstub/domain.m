% Return the first and last indices of sensor data
%
% INPUT
% this = sensor object
%
% OUTPUT
% a = integer index of first data element
% b = integer index of last data element


function [a,b]=domain(this)

a=this.cache.index(1);
b=this.cache.index(end);

end
