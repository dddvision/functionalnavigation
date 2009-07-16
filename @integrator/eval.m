% Transforms integrator noise into a 6-DOF trajectory respecting body dynamics


function x=eval(F,v)

K=size(v,2);
for k=1:K
  x(k)=integrator_eval_individual(F,v(:,k));
end
% HACK: should not have knowledge of ground truth trajectory
x(1)=trajectory('tposquat',[1,1.5;0,0;0,1.5;0,0;1,1;0,0;0,0;0,0;0,0]);

return;


function x=integrator_eval_individual(F,v)

dim=6;
t=0:0.01:1.5;
pnsc=0.02;
qnsc=0.1;

% HACK: number of bits should be negotiated externally
v=v(1:(end-mod(numel(v),dim)));
bpa=numel(v)/dim;
rate_bias=zeros(dim,1);
for d=1:dim
  rate_bias(d)=integrator_eval_bitmap(v((d-1)*bpa+(1:bpa)));
end

% HACK: should not call rand, only doing it now to create interesting visualization
omega=10*rand;
sint=sin(omega*t);

pnoise=pnsc*[rate_bias(1)*sint;rate_bias(2)*sint;rate_bias(3)*sint];
qnoise=qnsc*[rate_bias(4)*sint;rate_bias(5)*sint;rate_bias(6)*sint];

% HACK: should use a real dynamic model
p=[0*t;t;0.*t]+pnoise;
q=AxisAngle2Quat(qnoise);

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
