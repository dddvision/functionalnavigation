% Evaluate cost associated with trajectory and sensor noise sets
%
% INPUTS
% g = sensor data object
% x = trajectory objects, 1-by-K
% w = sensor noise objects, 1-by-K
% tmin = time domain lower bound
% tmax = time domain upper bound
%
% OUTPUT
% c = cost, 1-by-K
%
% NOTE
% The input trajectory objects represent the motion of the body frame
% relative to a world frame.  If the sensor frame is not coincident with
% the body frame, then transformations may be necessary.


function c=evaluate(g,x,w,tmin,tmax)

fprintf('\n');
fprintf('\n### Running @sensor/eval ###');

% get sensor event indices
[ka,kb]=domain(g);
k=ka:kb;

% identify sensor events within time domain bounds
t=gettime(g,k);
inside=find((t>=tmin)&(t<=tmax));
k=k(inside);
t=t(inside);

% check whether at least two events occurred
if( numel(inside)<2 )
  return;
end

% arbitrarily select the first and last events
ka=k(1);
kb=k(end);
ta=t(1);
tb=t(end);

% get data from sensor
ia=getdata(g,ka);
ib=getdata(g,kb);

%figure;
%imshow(ia);
%figure;
%imshow(ib);

% computing optical flow for two frames
o = opticalflow(ia, ib); 
[Vx_OF, Vy_OF] = computeOF(o);

% process each trajectory independently
K=numel(x);
c=zeros(1,K);
for k=1:K
  c(k)=sensor_evaluate_individual(g,x(k),w(:,k),Vx_OF,Vy_OF,ta,tb);
end

return;


function c=sensor_evaluate_individual(g,x,w,Vx_OF,Vy_OF,ta,tb)

% default cost
c=0.5;

% evaluate orientation of sensor
qa=evaluateQuaternion(x,ta);
qb=evaluateQuaternion(x,tb);

% evaluate position of sensor
pa=evaluatePosition(x,ta); 
pb=evaluatePosition(x,tb);
 
% convert quaternions to rotation matrices
Ra=Quat2Matrix(qa);
Rb=Quat2Matrix(qb);

% convert quaternions to Euler angles
Ea=Quat2Euler(qa);
Eb=Quat2Euler(qb);

% get focal parameter scale
rho=getfocal(g,w);

fprintf('\n');
fprintf('\nfocal: %0.4f',rho);
fprintf('\ntranslation: <%0.4f,%0.4f,%0.4f>',pb(1)-pa(1),pb(2)-pa(2),pb(3)-pa(3));
fprintf('\nrotation:\n');
disp(Ra'*Rb);
fprintf('\nEuler Angles: <%0.4f,%0.4f,%0.4f>\n',Eb(1)-Ea(1), Eb(2)-Ea(2), Eb(3)-Ea(3));

Trajectories = [];
Trajectories(1).Translation = [pb(1)-pa(1),pb(2)-pa(2),pb(3)-pa(3)];
Trajectories(1).Rotation = [Eb(1)-Ea(1), Eb(2)-Ea(2), Eb(3)-Ea(3)];
Trajectories(1).f = rho;

cost = computecost(Vx_OF,Vy_OF,Trajectories);
c = cost(1);

return;
