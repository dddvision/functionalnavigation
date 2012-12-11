function Y=Matrix2Euler(R)
% Copyright David D. Diel as of the most recent modification date.
% Permission is hereby granted to the following entities
% for unlimited use and modification of this document:
%   University of Central Florida
%   Massachusetts Institute of Technology
%   Draper Laboratory
%   Scientific Systems Company

Y=zeros(3,1); 

if isnumeric(R)
  Y(1)=atan2(R(3,2),R(3,3));
  Y(2)=asin(-R(3,1));
  Y(3)=atan2(R(2,1),R(1,1));
else
  Y=sym(Y);
  R=sym(R); 
  Y(1)=atan(R(3,2)/R(3,3));
  Y(2)=asin(-R(3,1));
  Y(3)=atan(R(2,1)/R(1,1));
end

return
