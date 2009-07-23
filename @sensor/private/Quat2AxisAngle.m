% Converts orientation representation from quaternion to axis angle
%
% INPUT
% Q = quaternions, 4-by-N
%
% OUTPUT
% V = axis angles, 3-by-N


function V=Quat2AxisAngle(Q)

Q=QuatNorm(Q);

q1=Q(1,:);
q2=Q(2,:);
q3=Q(3,:);
q4=Q(4,:);

theta=2*acos(q1);
n=sqrt(q2.*q2+q3.*q3+q4.*q4);

if isnumeric(Q)
  zt=[zeros(size(theta));theta];
  zt=unwrap(zt);
  theta=zt(2,:);
  ep=1E-12;
  n(n<ep)=ep;
end

a=q2./n;
b=q3./n;
c=q4./n;

v1=theta.*a;
v2=theta.*b;
v3=theta.*c;

V=[v1;v2;v3];

return;
