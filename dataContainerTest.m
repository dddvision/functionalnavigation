function dataContainerTest(container)
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
