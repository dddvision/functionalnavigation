% Calculates costs given seeds
%
% INPUT
% v = vectors of bit strings, vbits-by-popsize
% w = vectors of bit strings, wbits-by-popsize
%
% OUTPUT
% c = costs in the range [0,1], 1-by-popsize
%
% NOTES
% The objective object is returned in case it caches intermediate
% variables. Recycling the object through this function should not change
% the results, although it should execute more quickly on subsequent calls.


function [this,c]=evaluate(this,v,w)
    
%  zero or more trajectory objects from dynamic seeds
for k=1:size(v,2)
  F(k)=feval(this.xclass,v(:,k));
end
% % HACK: replace first trajectory with ground truth for testing
% switch(this.F)
%   case 'wobble_1.5'
%     x(1)=trajectory([1,1.5;0,0;0,1.5;0,0;1,1;0,0;0,0;0,0;0,0]);
%   otherwise
%     % do nothing
% end

% create zero or more sensor objects
g=feval(this.gclass);

% evaluate trajectories with sensors
c=evaluate(g,F,w,this.tmin,this.tmax);

% TODO: combine results from multiple sensors

% display all trajectories evenly
figure(4);
display(F,'tmin',this.tmin,'tmax',this.tmax);
axis('on');
xlabel('North');
ylabel('East');
zlabel('Down');

% display trajectories with variable transparency
figure(5);
pF=exp(-9*c.*c);
pF=pF/norm(pF);
display(F,'alpha',pF','tmin',this.tmin,'tmax',this.tmax);
axis('on');
xlabel('North');
ylabel('East');
zlabel('Down');

end
    