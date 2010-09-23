% Builds a pyramid of images and computes their gradients at multiple resolutions
%
% @param[in] f         image to process with dimensions that are a multiple of 2^(numLevels-1)
% @param[in] numLevels number of pyramid levels to create
% @return              pyramid structure with a cell for each level and fields for the image and its gradients
%
% NOTES
% Gradients are computed using the central difference formula
% gx is the gradient along the contiguous image dimension
% gy is the gradient along the non-contiguous image dimension
function pyramid =buildPyramid(f, numLevels)

  pyramid = cell(numLevels,1);

  for level=1:numLevels
    if(level>1)
      f=imageReduce(f);
    end
    
    [gx,gy]=imageGradient(f);
    
    pyramid{level}.f=f;
    pyramid{level}.gx=gx;
    pyramid{level}.gy=gy;
  end

end

% Computes the gradient using the central difference formula
function [gx, gy] = imageGradient(f)
  gx=diff(f,1,1);
  gy=diff(f,1,2);
  gx=([gx(1,:);gx]+[gx;gx(end,:)])/2;
  gy=([gy(:,1),gy]+[gy,gy(:,end)])/2;
end

% Reduces image to half resolution
function x = imageReduce(x)
  [m,n]=size(x);
  if( mod(m,2)||mod(n,2) )
    error('Image height and width must be multiples of 2');
  end
  x=x(1:2:end,:)+x(2:2:end,:);
  x=x(:,1:2:end)+x(:,2:2:end);
  x=x/4;
end
