% Evaluate a single trajectory at multiple time instants


function posquat=evaluate(this,t)

switch( this.type )
  case 'tposquat'
    [a,b]=domain(this);
    t(t<a)=a;
    t(t>b)=b;
    pt=interp1(this.data(1,:),this.data(2:4,:)',t,'linear')';
    qt=interp1(this.data(1,:),this.data(5:8,:)',t,'nearest')';
    posquat=[pt;qt];
  case 'wobble_1.5'
    [a,b]=domain(this);
    t(t<a)=a;
    t(t>b)=b;
    posquat=trajectory_evaluate_wobble(this.data,t);
  case 'analytic'
    posquat=eval(this.data.eval);
  case 'empty'
    posquat=[];
  otherwise
    error('unhandled exception');
end

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
  dec=bin2dec(num2str(bits));
  rate_bias(d)=2*dec/(2^bpa-1)-1;
end

vomega=v(1:omegabits)';
dec=bin2dec(num2str(vomega));
omega=scaleomega*(2*dec/(2^omegabits-1)-1);
sint=sin(omega*t);

pnoise=scalep*[rate_bias(1)*sint;rate_bias(2)*sint;rate_bias(3)*sint];
qnoise=scaleq*[rate_bias(4)*sint;rate_bias(5)*sint;rate_bias(6)*sint];

posquat=[[0*t;t;0.*t]+pnoise;
         AxisAngle2Quat(qnoise)];

return;
    