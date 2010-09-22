% Reduce image to half resolution
function x = Reduce(x)
  [m,n]=size(x);
  if( mod(m,2)||mod(n,2) )
    error('Image height and width must be multiples of 2');
  end
  x=x(1:2:end,:)+x(2:2:end,:);
  x=x(:,1:2:end)+x(:,2:2:end);
  x=x/4;
end
