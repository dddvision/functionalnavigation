% Transforms integrator noise into a 6-DOF trajectory respecting body dynamics


function x=eval(F,v)

K=size(v,2);
for k=1:K
  x(k)=integrator_eval_individual(F,v(:,k));
end
% HACK: insert ground truth trajectory
x(1)=trajectory('tposquat',[0,1.5;0,0;0,1.5;0,0;1,1;0,0;0,0;0,0;0,0]);

return;


function x=integrator_eval_individual(F,v)

dim=6;
v=v(1:(end-mod(numel(v),dim))); % make length divisible by dim
bpa=numel(v)/6; % bits per axis
rate_bias=zeros(dim,1);
for d=1:dim
  rate_bias(d)=integrator_eval_bitmap(v((d-1)*bpa+(1:bpa)));
end

t=0:0.01:1.5;
pnoise=[rate_bias(1)*t;rate_bias(2)*t;rate_bias(3)*t];
qnoise=[rate_bias(4)*t;rate_bias(5)*t;rate_bias(6)*t];

% TODO: use a real dynamic model
p=[0.*t;t;0.*t]+pnoise/10;
q=AxisAngle2Quat(qnoise/10);

type='tposquat';
data=[t;p;q];
x=trajectory(type,data);

return;


function z=integrator_eval_bitmap(bits)
B=numel(bits);
bits=reshape(bits,[1,B]);
dec=bin2dec(num2str(bits));
z=2*dec/(2^B-1)-1;
return;
