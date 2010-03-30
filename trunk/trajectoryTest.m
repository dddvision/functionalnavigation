function trajectoryTest(x)
  assert(isa(x,'trajectory'));
  [a,b]=domain(x);
  t=a:b;
  [p,q]=evaluate(x,t);
  figure;
  plot3(p(1,:),p(2,:),p(3,:),'b.');
  figure;
  plot3(q(2,:),q(3,:),q(4,:));
end
