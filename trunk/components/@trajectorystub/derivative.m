function posquatdot=derivative(this,t)
  N=numel(t);
  [a,b]=domain(this);
  posquatdot=zeros(7,N);
  posquatdot(2,:)=1;
  posquatdot(:,t<a|t>b)=NaN;
end
    