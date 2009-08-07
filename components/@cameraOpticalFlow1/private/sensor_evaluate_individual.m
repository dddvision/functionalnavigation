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

end
