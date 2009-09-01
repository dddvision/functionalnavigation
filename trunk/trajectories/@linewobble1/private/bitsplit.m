% INPUT
% b = bits, logical 1-by-N or N-by-1
%
% OUTPUT
% z = number in the range [0,1]
function z=bitsplit(b)
  N=numel(b);
  z=0.5;
  dz=0.25;
  for n=1:N
    if(b(n))
      z=z+dz;
    else
      z=z-dz;
    end
    dz=dz/2;
  end
end