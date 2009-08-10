% TODO: implement this function
function posquatdot=derivative(this,t)
  warning('derivative of this trajectory type is not yet supported');
  N=numel(t);
  [a,b]=domain(this);
  posquatdot=zeros(7,N);
  posquatdot(:,t<a|t>b)=NaN;
end
    