% Return trajectory position components at several time instants
%
% INPUTS
% x = trajectory object
% t = time at which to evaluate the trajectory
%
% OUTPUT
% pt = position at the given time instant 


function pt=evaluatePosition(x,t)
pqt=evaluate(x,t);
pt=pqt(1:3,:);
return;