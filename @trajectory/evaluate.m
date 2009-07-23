% Evaluate a single trajectory at multiple time instants
%
% INPUT
% x = single trajectory object
% t = time in seconds
%
% NOTE
% Axis order is forward-right-down relative to the base reference frame


% TODO: evaluation outside of time domain should return undefined or NaN
function posquat=evaluate(x,t)

switch( x.type )
  case 'tposquat'
    [a,b]=domain(x);
    t(t<a)=a;
    t(t>b)=b;
    pt=interp1(x.data(1,:),x.data(2:4,:)',t,'linear')';
    qt=interp1(x.data(1,:),x.data(5:8,:)',t,'nearest')';
    posquat=[pt;qt];
  case 'wobble_1.5'
    [a,b]=domain(x);
    t(t<a)=a;
    t(t>b)=b;
    posquat=trajectory_evaluate_wobble(x.data,t);
  case 'pendulum_1.5'
    [a,b]=domain(x);
    t(t<a)=a;
    t(t>b)=b;
    posquat=trajectory_evaluate_pendulum(x.data,t);
  case 'analytic'
    posquat=eval(x.data.eval);
  case 'empty'
    posquat=[];
  otherwise
    error('unhandled exception');
end

return;


function posquat=trajectory_evaluate_pendulum(v,t)

thetao=pi/2+0.1*bitsplit(v');
b=0.1;
w=2;

theta=thetao*exp(-b*t).*cos(w*t);

N=numel(t);
posquat=[zeros(1,N);-0.1*sin(theta);0.1*cos(theta);cos(theta/2);sin(theta/2);zeros(2,N)];

return;


% HACK: should use a meaningful dynamic model of a real system
% HACK: the number of bits in v should be negotiated externally
function posquat=trajectory_evaluate_wobble(v,t)

dim=6;
scalep=0.02;
scaleq=0.1;

omegabits=6;
scaleomega=10;

vaxis=v((omegabits+1):(end-mod(numel(v),dim)));
bpa=numel(vaxis)/dim;
rate_bias=zeros(dim,1);
for d=1:dim
  bits=vaxis((d-1)*bpa+(1:bpa))';
  rate_bias(d)=(1-2*bitsplit(bits));
end

bits=v(1:omegabits)';
omega=scaleomega*(1-2*bitsplit(bits));
sint=sin(omega*t);

pnoise=scalep*[rate_bias(1)*sint;rate_bias(2)*sint;rate_bias(3)*sint];
qnoise=scaleq*[rate_bias(4)*sint;rate_bias(5)*sint;rate_bias(6)*sint];

posquat=[[0*t;t;0.*t]+pnoise;
         AxisAngle2Quat(qnoise)];

return;


% INPUT
% b = logical bits, 1-by-N or N-by-1
%
% OUTPUT
% z = number in the range [0,1]
function z=bitsplit(b)
N=numel(b);
z=0.5;
dz=0.25;
for n=1:N
  if(b(n))
    z=z+dz;
  else
    z=z-dz;
  end
  dz=dz/2;
end
return;

    