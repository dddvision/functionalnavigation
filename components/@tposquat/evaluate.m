% TODO: use slerp interpolation for quaternions
function posquat=evaluate(x,t)
  [a,b]=domain(x);
  bad=t<a|t>b;
  t(t<a)=a;
  t(t>b)=b;
  pt=interp1(x.data(1,:),x.data(2:4,:)',t,'linear')';
  qt=interp1(x.data(1,:),x.data(5:8,:)',t,'nearest')';
  posquat=[pt;qt];
  posquat(:,bad)=NaN;
end
    