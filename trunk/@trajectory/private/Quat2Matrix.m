% Converts a set of quaternions to a set of rotation matrices.
%
% Q = body orientation states in quaternion <scalar,vector> form (4-by-n)
% R = matrices that rotate a point from the body frame to the world frame
% (3-by-3-by-n)


function R=Quat2Matrix(Q)

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

R=zeros(3,3,n);
if( ~isnumeric(Q) )
  R=sym(R);
end
  
R(1,1,:) = q11 + q22 - q33 - q44;
R(2,1,:) = 2*(q23 + q14);
R(3,1,:) = 2*(q24 - q13);

R(1,2,:) = 2*(q23 - q14);
R(2,2,:) = q11 - q22 + q33 - q44;
R(3,2,:) = 2*(q34 + q12);

R(1,3,:) = 2*(q24 + q13);
R(2,3,:) = 2*(q34 - q12);
R(3,3,:) = q11 - q22 - q33 + q44;

end
