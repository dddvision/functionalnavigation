% by Y. Ma, S. Soatto, J. Kosecka, S. Sastry (MASKS)
%
% Code distributed free for non-commercial use
% Copyright (c) MASKS, 2003

function [T0,R0,E]  = dessential(p,q)

n = size(p);
NPOINTS = n(2);

%set up matrix A such that A*[v1,v2,v3,s1,s2,s3,s4,s5,s6]' = 0
A = zeros(NPOINTS, 9);

if NPOINTS < 9
     error('Too few mesurements')
     return;
end

for i = 1:NPOINTS
  A(i,:) = kron(q(:,i),p(:,i))';
  end
r = rank(A);

if r < 8 
  error('Measurement matrix rank defficient')
end;

[U,S,V] = svd(A);
% pick the eigenvector corresponding to the smallest eigenvalue
eigs98 = [S(9,9), S(8,8)];
e = V(:,9);
e = (round(1.0e+10*e))*(1.0e-10);
E = reshape(e, 3, 3)';  % essential matrix 

% then four possibilities are 
Rzp = [0 -1 0 ; 1 0 0 ; 0 0 1 ]; % rotation by pi/2
Rzn = [0 1 0 ; -1 0 0 ; 0 0 1 ]; % rotation by -pi/2

[U,S,V] = svd(E);
S = diag([1,1,0]);
detu = det(U);
detv = det(V);
if detu < 0 & detv < 0
   U = -U; V = -V;
   % break
elseif detu < 0 & detv > 0
   S1 = Rzp*S;
   U  = -U*rot_matrix([S1(3,2), S1(1,3) S1(2,1)],pi)*Rzp;
   V  = V*Rzp;
   % break   
elseif detu > 0 & detv < 0
   S1 = Rzp*S;
   U = U*rot_matrix([S1(3,2), S1(1,3) S1(2,1)],pi)*Rzp;
   V = -V*Rzp;
   % break
end
R(:,:,1) = (U*Rzp'*V');
Th(:,:,1) = (U*Rzp*S*U');
t(:,1)  = [-Th(2,3,1), Th(1,3,1), -Th(1,2,1)]';
[omega(:,1),theta(1)] = exp_rotation(R(:,:,1));
R(:,:,2) = (U*Rzn'*V');
Th(:,:,2)  = (U*Rzn*S*U');
t(:,2)  = [-Th(2,3,2), Th(1,3,2), -Th(1,2,2)]';
[omega(:,2),theta(2)] = exp_rotation(R(:,:,2));        

[U,S,V] = svd(-E);
S = diag([1,1,0]);
detu = det(U);
detv = det(V);

if detu < 0 & detv < 0
   U = -U; V = -V;
   % break
elseif detu < 0 & detv > 0
   S1 = Rzp*S;
   U  = -U*rot_matrix([S1(3,2), S1(1,3) S1(2,1)],pi)*Rzp;
   V  = V*Rzp;
   % break   
elseif detu > 0 & detv < 0
   S1 = Rzp*S;
   U = U*rot_matrix([S1(3,2), S1(1,3) S1(2,1)],pi)*Rzp;
   V = -V*Rzp;
end

R(:,:,3) = (U*Rzp'*V');
Th(:,:,3) = U*Rzp*S*U';
t(:,3) = [-Th(2,3,3), Th(1,3,3), -Th(1,2,3)]';
[omega(:,3),theta(3)] = exp_rotation(R(:,:,3));       
R(:,:,4) = (U*Rzn'*V');
Th(:,:,4)   = U*Rzn*S*U';
t(:,4)  = [-Th(2,3,4), Th(1,3,4), -Th(1,2,4)]';
[omega(:,4),theta(4)] = exp_rotation(R(:,:,4));       

   index = 0;
   posdepth = zeros(1,4);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % pick the correct solution based on positive depth constraint
   % there are two ways (below 2. is used):
   % 1. Compute both scales and pick the solution where the majority is 
   %    positive in both frames
   % 2. Compute volume, which has to be positive if the two scales have 
   %     the same sign and then check whether one of the scale is positive
   %     (similar solution suggested by Kanatani, 1993 book).
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   for i = 1:4
     for j = 1:NPOINTS
     % c (a x b) (That*q)'*That*R*p > 0 
     % if the depths have the same sign the triple product has to 
     % be greater then 0 
     volume(j) =  triple_product(t(:,i), R(:,:,i)*p(:,j), Th(:,:,i)*q(:,j));
     alpha1(j) = -(skew(q(:,j))*t(:,i))'*...
                 (skew(q(:,j))*R(:,:,i)*p(:,j)) ...
                 /(norm(skew(q(:,j))*t(:,i)))^2;
     alpha2(j) = (skew(R(:,:,i)*p(:,j))*q(:,j))'*...
                 (skew(R(:,:,i)*p(:,j))*t(:,i)) ...
                 /norm(skew(R(:,:,i)*p(:,j))*q(:,j))^2;
     end
     vol = sum(sign(volume));
     depth = sum(sign(alpha1));
     depth2 = sum(sign(alpha2));
     posdepth(i) = vol +  depth;
   end     % end for all motions

 [val, index] = max(posdepth);
 index_final = index;
 T0 = t(:,index);
 R0 = R(:,:,index);

