function c=evaluate(this,x,tmin)

fprintf('\n');
fprintf('\n%s::evaluate',class(this));

fprintf('\ntmin = %f',tmin);

% get sensor event indices
[ka,kb]=domain(this);
k=ka:kb;

% identify sensor events within time domain bounds
t=gettime(this,k);
inside=find(t>=tmin);
k=k(inside);
t=t(inside);

% check whether at least two events occurred
if( numel(inside)<2 )
  c=1;
  return;
end

% arbitrarily select the first and last events
ka=k(1);
kb=k(end);
ta=t(1);
tb=t(end);

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

% get optical flow from cache
data=cameraOpticalFlow1_cache(this,ka,kb);

% get focal parameter scale
rho=getfocal(this);

testTrajectory.f = rho;
testTrajectory.Translation = [pb(1)-pa(1),pb(2)-pa(2),pb(3)-pa(3)];
testTrajectory.Rotation = [Eb(1)-Ea(1),Eb(2)-Ea(2),Eb(3)-Ea(3)];

fprintf('\nfocal = %f',testTrajectory.f);
fprintf('\ntranslation = < %f %f %f >',...
  testTrajectory.Translation(1),...
  testTrajectory.Translation(2),...
  testTrajectory.Translation(3));
fprintf('\nrotation angles = < %f %f %f >',...
  testTrajectory.Rotation(1),...
  testTrajectory.Rotation(2),...
  testTrajectory.Rotation(3));

% compute the cost
c=computecost(data.Vx_OF,data.Vy_OF,testTrajectory);

fprintf('\ncost = %f',c);

end
