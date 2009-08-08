% HACK: should use a meaningful dynamic model of a real system
% HACK: the number of bits in v should be negotiated externally
function posquat=evaluate(x,t)

v=x.data;
[a,b]=domain(x);

t(t<a|t>b)=NaN;

thetao=pi/2+0.1*bitsplit(v');
b=0.1;
w=2;

theta=thetao*exp(-b*t).*cos(w*t);

N=numel(t);
posquat=[zeros(1,N);-0.1*sin(theta);0.1*cos(theta);cos(theta/2);sin(theta/2);zeros(2,N)];

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

    