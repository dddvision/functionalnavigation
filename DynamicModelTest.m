function DynamicModelTest(packageName,initialTime,uri)
  fprintf('\npackagename =');
  assert(isa(packageName,'char'));
  fprintf(' ''%s''',packageName);

  fprintf('\ninitialTime =');
  assert(isa(initialTime,'WorldTime')); 
  fprintf(' %f',double(initialTime));

  fprintf('\nuri =');
  assert(isa(uri,'char'));
  fprintf(' ''%s''',uri);
  
  fprintf('\nfactory =');
  dynamicModel=DynamicModel.factory(packageName,initialTime,uri);
  assert(isa(dynamicModel,'DynamicModel'));
  fprintf(' ok');
  
  fprintf('\ndomain =');
  interval=domain(dynamicModel);
  assert(isa(interval,'TimeInterval'));
  assert(interval.first==initialTime);
  fprintf(' ok');
  
  fprintf('\nnumInitialLogical =');
  nIL=numInitialLogical(dynamicModel);
  assert(isa(nIL,'uint32'));
  fprintf(' %d',nIL);
  
  fprintf('\nnumInitialUint32 =');
  nIU=numInitialUint32(dynamicModel);
  assert(isa(nIU,'uint32'));
  fprintf(' %d',nIU);  
  
  fprintf('\nnumExtensionLogical =');
  nEL=numExtensionLogical(dynamicModel);
  assert(isa(nEL,'uint32'));
  fprintf(' %d',nEL); 
  
  fprintf('\nnumExtensionUint32 =');
  nEU=numExtensionUint32(dynamicModel);
  assert(isa(nEU,'uint32'));
  fprintf(' %d',nEU);
  
  fprintf('\ngetInitialLogical =');
  vIL=false(nIL,1);
  for p=uint32(1):nIL
    v=getInitialLogical(dynamicModel,p-uint32(1));
    assert(isa(v,'logical'));
    fprintf(' %d',v);
    vIL(p)=v;
  end
  
  fprintf('\ngetInitialUint32 =');
  vIU=zeros(nIU,1,'uint32');
  for p=uint32(1):nIU
    v=getInitialUint32(dynamicModel,p-uint32(1));
    assert(isa(v,'uint32'));
    fprintf(' %d',v);
    vIU(p)=v;
  end
  
  testState(dynamicModel,interval.first);

  % TODO: test that output is deterministic
  v=uint32(5);
  
  if(~isinf(interval.second))
    for b=uint32(0:3)
      fprintf('\nextend');
      extend(dynamicModel);
      for p=uint32(0:(nEU-1))
        setExtensionUint32(dynamicModel,b,p,v);
      end
      time=WorldTime(interval.second);
      testState(dynamicModel,time);
      time=WorldTime(this.alpha*interval.first+(1-this.alpha)*interval.second);
      testState(dynamicModel,time);
    end
  end
end

function testState(dynamicModel,time)
  fprintf('\n\ntime = %f',double(time));

  numBlocks=numExtensionBlocks(dynamicModel);
  assert(isa(numBlocks,'uint32'));
  fprintf('\nnumBlocks = %d',numBlocks);
  
  interval=domain(dynamicModel);
  display(interval);
  
  pose=evaluate(dynamicModel,time);
  assert(isa(pose,'Pose'));
  display(pose); 
  
  tangentPose=tangent(dynamicModel,time);
  assert(isa(tangentPose,'TangentPose'));
  display(tangentPose);
end
