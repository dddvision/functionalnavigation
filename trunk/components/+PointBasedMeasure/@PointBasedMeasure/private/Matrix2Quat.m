function Q=Matrix2Quat(M)
%this transformation has no nice direct method
%the best method is to convert to Euler angles first, then to quaternions
%
% Copyright David D. Diel as of the most recent modification date.
% Permission is hereby granted to the following entities
% for unlimited use and modification of this document:
%   University of Central Florida
%   Massachusetts Institute of Technology
%   Draper Laboratory
%   Scientific Systems Company

Y=Matrix2Euler(M);
Q=Euler2Quat(Y);

return
