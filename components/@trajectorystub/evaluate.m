function posquat=evaluate(this,t)
  N=numel(t);
  [a,b]=domain(this);
  posquat=repmat(this.pose,[1,N]);
  posquat(2,:)=t;
  posquat(:,t<a|t>b)=NaN;
end
    