% Normalize each quaternion to have unit magnitude and positive first element
%
% INPUT/OUTPUT
% Q = quaternions (4-by-n)


function Q=QuatNorm(Q)

%verify size
if size(Q,1)~=4
  error('argument must be 4-by-n');
end

%handle symbolic input
if ~isnumeric(Q)
  return;
end

%extract elements
q1=Q(1,:);
q2=Q(2,:);
q3=Q(3,:);
q4=Q(4,:);

%normalization factor
n=sqrt(q1.*q1+q2.*q2+q3.*q3+q4.*q4);

%handle small normalization factors
bad=find(abs(n-1)>0.00001);
if ~isempty(bad)
  warning('quaternion is poorly scaled');
end

%handle negative first element
s=sign(q1);
s(find(s==0))=1;
ns=n.*s;

%normalize
Q(1,:)=q1./ns;
Q(2,:)=q2./ns;
Q(3,:)=q3./ns;
Q(4,:)=q4./ns;

return