function cost=evaluate(this,x,tmin)

fprintf('\n');
fprintf('\nopticalFlowPDollar::evaluate');

fprintf('\ntmin = %f',tmin);

% arbitrarily select the last and next-to-last images
[ka,kb]=domain(this.cameraHandle);
ka=max(ka,kb-1);

% get optical flow from cache
data=opticalFlow1_cache(this,ka,kb);

% get corresponding times
ta=getTime(this.cameraHandle,ka);
tb=getTime(this.cameraHandle,kb);

% evaluate sensor position and orientation
pqa=evaluate(x,ta);
pqb=evaluate(x,tb);
pa=pqa(1:3,:);
qa=pqa(4:7,:);
pb=pqb(1:3,:);
qb=pqb(4:7,:);
 
% convert quaternions to Euler angles
Ea=Quat2Euler(qa);
Eb=Quat2Euler(qb);

% TODO: handle case where focal length is different at ka and kb
testTrajectory.f = 100;
testTrajectory.Translation = [pb(1)-pa(1),pb(2)-pa(2),pb(3)-pa(3)];
testTrajectory.Rotation = [Eb(1)-Ea(1),Eb(2)-Ea(2),Eb(3)-Ea(3)];

fprintf('\ntranslation = < %f %f %f >',...
  testTrajectory.Translation(1),...
  testTrajectory.Translation(2),...
  testTrajectory.Translation(3));
fprintf('\nrotation angles = < %f %f %f >',...
  testTrajectory.Rotation(1),...
  testTrajectory.Rotation(2),...
  testTrajectory.Rotation(3));

% compute the cost
cost=computecost(data.Vx_OF,data.Vy_OF,testTrajectory);
fprintf('\ncost = %f',cost);

end
