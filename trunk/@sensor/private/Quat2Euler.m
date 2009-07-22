% Converts a set of quaternions to a set of Euler angles
%
% Q = body orientation states in quaternion <scalar,vector> form (4-by-n)
% E = Euler angles by which the body rotates, in the order forward-right-down


function E=Quat2Euler(Q)

n=size(Q,2);
Q=QuatNorm(Q);

q1=Q(1,:);
q2=Q(2,:);
q3=Q(3,:);
q4=Q(4,:);

q11=q1.*q1;
q22=q2.*q2;
q33=q3.*q3;
q44=q4.*q4;

q12=q1.*q2;
q23=q2.*q3;
q34=q3.*q4;
q14=q1.*q4;
q13=q1.*q3;
q24=q2.*q4;

E=zeros(3,n);

E(1,:) = atan2(2*(q34-q12), q11-q22-q33+q44);
E(2,:) = asin(-2*(q24+q13));
E(3,:) = atan2(2*(q23-q14), q11+q22-q33-q44);

return