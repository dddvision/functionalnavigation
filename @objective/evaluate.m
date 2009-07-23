% Calculates costs given seeds
%
% INPUT
% H = objective object
% v = vectors of bit strings, N-by-popsize
% w = vectors of bit strings, M-by-popsize
% tmin = time domain lower bound
% tmax = time domain upper bound
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

% create trajectory objects from dynamic seeds
x=trajectory(H.F,v);

% HACK: replace first trajectory with ground truth for testing
switch(H.F)
  case 'wobble_1.5'
    x(1)=trajectory('tposquat',[1,1.5;0,0;0,1.5;0,0;1,1;0,0;0,0;0,0;0,0]);
  otherwise
    % do nothing
end
  
% evaluate trajectories with sensors
c=evaluate(H.g,x,w,H.tmin,H.tmax);

% TODO: combine results from multiple sensors

% display trajectories with variable transparency
figure;
display(x,'alpha',1-c,'tmin',H.tmin,'tmax',H.tmax);
axis('on');
xlabel('North');
ylabel('East');
zlabel('Down');

return;
