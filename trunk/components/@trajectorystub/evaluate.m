% Evaluate a single trajectory at multiple time instants
%
% INPUT
% t = time in seconds, 1-by-N
%
% OUTPUT
% posquat = position and quaternion at each time, 7-by-N
%
% NOTE
% Axis order is forward-right-down relative to the base reference frame


function posquat=evaluate(this,t)
  N=numel(t);
  [a,b]=domain(this);
  posquat=repmat(this.pose,[1,N]);
  posquat(:,(t<a|t>b))=NaN;
end
    