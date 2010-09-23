% Builds a pyramid of images and computes their gradients at multiple resolutions
function pyramid =BuildPyramid(f, levels)

  pyramid = cell(levels,1);

  [gx,gy]=grad(f);
  pyramid{1}.f=f;
  pyramid{1}.gx=gx;
  pyramid{1}.gy=gy;

  for L=2:levels
    f=Reduce(f);
    [gx,gy]=grad(f);

    pyramid{L}.f=f;
    pyramid{L}.gx=gx;
    pyramid{L}.gy=gy;
  end

end

% Computes the gradient using the central difference formula
function [gx, gy] = grad(f)
  gx=diff(f,1,1);
  gy=diff(f,1,2);
  gx=([gx(1,:);gx]+[gx;gx(end,:)])/2;
  gy=([gy(:,1),gy]+[gy,gy(:,end)])/2;
end

% Reduces image to half resolution
function x = Reduce(x)
  [m,n]=size(x);
  if( mod(m,2)||mod(n,2) )
    error('Image height and width must be multiples of 2');
  end
  x=x(1:2:end,:)+x(2:2:end,:);
  x=x(:,1:2:end)+x(:,2:2:end);
  x=x/4;
end

