% Testbed for TOMMAS components
%
% INPUT
% componentString = name of the package containing the component, string
function testbed(componentString)
  component=unwrapComponent(componentString);
  switch(component.baseClass)
    case 'dataContainer'
      testDataContainer(component);
    case 'dynamicModel'
      testDynamicModel(component);
    case 'measure'
      testMeasure(component);
    case 'optimizer'
      testOptimizer(component);
    otherwise
      warning('testComponent:exception','unrecognized component type');
  end      
end

function testDataContainer(container)
  assert(isa(container,'dataContainer'));
  if(hasReferenceTrajectory(container))
    x=getReferenceTrajectory(container);
    trajectoryTest(x);
  end
  list=listSensors(container,'sensor');
  for k=1:numel(list)
    u=getSensor(container,list(k));
    assert(isa(u,'sensor'));
  end
end

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
