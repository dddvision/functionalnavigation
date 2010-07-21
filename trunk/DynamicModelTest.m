function DynamicModelTest(packageName,initialTime,uri)
  assert(isa(packageName,'char'));
  fprintf('\npackagename = ''%s''\n',packageName);

  assert(isa(initialTime,'WorldTime')); 
  fprintf('\ninitialTime = %f\n',double(initialTime));

  assert(isa(uri,'char'));
  fprintf('\nuri = ''%s''\n',uri);
  
  dynamicModel=DynamicModel.factory(packageName,initialTime,uri);
  assert(isa(dynamicModel,'DynamicModel'));
  
  initialLogical=numInitialLogical(dynamicModel);
  assert(isa(initialLogical,'uint32'));
  fprintf('\ninitialLogical = %d',initialLogical);
  
  initialUint32=numInitialUint32(dynamicModel);
  assert(isa(initialUint32,'uint32'));
  fprintf('\ninitialUint32 = %d',initialUint32);  
  
  extensionLogical=numExtensionLogical(dynamicModel);
  assert(isa(extensionLogical,'uint32'));
  fprintf('\nextensionLogical = %d',extensionLogical); 
  
  extensionUint32=numExtensionUint32(dynamicModel);
  assert(isa(extensionUint32,'uint32'));
  fprintf('\nextensionUint32 = %d\n',extensionUint32);
  
  testCurrentState(dynamicModel);
  
  % TODO: test ability to set and retrieve parameters
  % TODO: test that output is deterministic
  interval=domain(dynamicModel);
  assert(interval.first==initialTime);
  assert(interval.second==initialTime);
  
  v=uint32(5);
  
  for b=uint32(0:3)
    fprintf('\nextend');
    extend(dynamicModel);
    for p=uint32(0:(extensionUint32-1))
      setExtensionUint32(dynamicModel,b,p,v);
    end
    testCurrentState(dynamicModel);
  end
end

function testCurrentState(dynamicModel)
  numBlocks=numExtensionBlocks(dynamicModel);
  assert(isa(numBlocks,'uint32'));
  fprintf('\nnumBlocks = %d\n',numBlocks);
  
  interval=domain(dynamicModel);
  assert(isa(interval,'TimeInterval'));
  display(interval);
  
  alpha=10*eps;
  
  pose=evaluate(dynamicModel,interval.second);
  assert(isa(pose,'Pose'));
  display(pose);
  
  pose=evaluate(dynamicModel,WorldTime(alpha*interval.first+(1-alpha)*interval.second));
  assert(isa(pose,'Pose'));
  display(pose); 
  
  tangentPose=tangent(dynamicModel,interval.second);
  assert(isa(tangentPose,'TangentPose'));
  display(tangentPose);
  
  tangentPose=tangent(dynamicModel,WorldTime(alpha*interval.first+(1-alpha)*interval.second));
  assert(isa(tangentPose,'TangentPose'));
  display(tangentPose);
end
