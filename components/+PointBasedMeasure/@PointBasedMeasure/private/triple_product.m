% triple product of three vectors (a x b) c 
% corresponds to the volume spanned by them
% Copyright 2011 University of Central Florida, New BSD License
function[volume] = triple_product(a,b,c)

volume = c(1)*(a(2)*b(3) - b(2)*a(3)) + c(2)*(a(3)*b(1) - b(3)*a(1)) + ...
          c(3)*(a(1)*b(2) - b(1)*a(2));
