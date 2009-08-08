% HACK: should use a meaningful dynamic model of a real system
% HACK: the number of bits in v should be negotiated externally
function posquat=evaluate(x,t)

v=x.data;
[a,b]=domain(x);

t(t<a|t>b)=NaN;

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

end


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
end

    