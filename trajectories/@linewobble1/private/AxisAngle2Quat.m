% Converts orientation representation from Axis-Angle to Quaternion
%
% INPUT
% v = axis angle vectors, 3-by-N
%
% OUTPUT
% q = quaternion vectors, 4-by-N
%
% NOTES
% Does not preserve wrap-around


function q=AxisAngle2Quat(v)

v1=v(1,:);
v2=v(2,:);
v3=v(3,:);

n=sqrt(v1.*v1+v2.*v2+v3.*v3);

if isnumeric(v)
  ep=1E-12;
  n(n<ep)=ep;
end
  
a=v1./n;
b=v2./n;
c=v3./n;

if isnumeric(v)
  zn=[zeros(size(n));n];
  zn=unwrap(zn);
  n=zn(2,:);
end

th2=n/2;
s=sin(th2);

q1=cos(th2);
q2=s.*a;
q3=s.*b;
q4=s.*c;

q=[q1;q2;q3;q4];

q=QuatNorm(q);

end
