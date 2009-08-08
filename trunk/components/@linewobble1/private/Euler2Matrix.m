function M=Euler2Matrix(Y)
%Y must be a 3-element Euler-angle vector
%
% Copyright David D. Diel as of the most recent modification date.
% Permission is hereby granted to the following entities
% for unlimited use and modification of this document:
%   University of Central Florida
%   Massachusetts Institute of Technology
%   Draper Laboratory
%   Scientific Systems Company

Y1=Y(1);
Y2=Y(2);
Y3=Y(3);

c1=cos(Y1);
c2=cos(Y2);
c3=cos(Y3);

s1=sin(Y1);
s2=sin(Y2);
s3=sin(Y3);

M=zeros(3);

if( ~isnumeric(Y) )
  M=sym(M);
end
  
M(1,1)=c3.*c2;
M(1,2)=c3.*s2.*s1-s3.*c1;
M(1,3)=s3.*s1+c3.*s2.*c1;

M(2,1)=s3.*c2;
M(2,2)=c3.*c1+s3.*s2.*s1;
M(2,3)=s3.*s2.*c1-c3.*s1;

M(3,1)=-s2;
M(3,2)=c2.*s1;
M(3,3)=c2.*c1;

end
