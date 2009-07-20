% Calculates costs given seeds
%
% INPUT
% H = objective object
% v = vectors of bit strings, N-by-popsize
% w = vectors of bit strings, M-by-popsize
%
% OUTPUT
% H = essentially unmodified objective object
% c = costs in the range [0,1], 1-by-popsize
%
% NOTES
% The objective object is returned in case it caches intermediate
% variables. Recycling the object through this function should not change
% the results, although it should execute more quickly on subsequent
% calls.


function [H,c] = evaluate(H,v,w)

x=evaluate(H.F,v);
c=evaluate(H.g,x,w);

figure;
display(x,'alpha',1-c);
axis('on');
xlabel('North');
ylabel('East');
zlabel('Down');

return;
