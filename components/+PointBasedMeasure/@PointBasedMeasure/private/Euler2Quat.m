% Converts Euler angles to quaternions


function Q=Euler2Quat(E)

a=E(1,:);
b=E(2,:);
c=E(3,:);

c1=cos(a/2);
c2=cos(b/2);
c3=cos(c/2);

s1=sin(a/2);
s2=sin(b/2);
s3=sin(c/2);

Q(1,:) = c3.*c2.*c1 + s3.*s2.*s1;
Q(2,:) = c3.*c2.*s1 - s3.*s2.*c1;
Q(3,:) = c3.*s2.*c1 + s3.*c2.*s1;
Q(4,:) = s3.*c2.*c1 - c3.*s2.*s1;

Q=QuatNorm(Q);

return
