% HACK: should use a meaningful dynamic model of a real system
% HACK: the number of bits in v should be negotiated externally
function posquat=evaluate(this,t)

v=this.data;
[a,b]=domain(this);

t(t<a|t>b)=NaN;

thetao=pi/2+0.1*bitsplit(v');

theta=thetao*exp(-this.damp*t).*cos(this.omega*t);

N=numel(t);
posquat=[zeros(1,N);-0.1*sin(theta);0.1*cos(theta);cos(theta/2);sin(theta/2);zeros(2,N)];

end


% INPUT
% b = bits, logical 1-by-N or N-by-1
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

    