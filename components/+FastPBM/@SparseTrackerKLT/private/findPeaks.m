% Select semi-uniformly spaced pixels that represent the local maximum within a window
%
% @param[in]  img     image to process
% @param[in]  halfwin half of the window size to process
% @param[in]  num     number of feature locations to select
% @param[out] x       one-based position of peak in the contiguous dimension
% @param[out] y       one-based position of peak in the non-contiguous dimension
function [x, y] = findPeaks(img, halfwin, num)
  [M, N] = size(img);
  w = -halfwin:halfwin;
  [xx,yy] = ndgrid(w,w);
  xMin = 1+halfwin;
  yMin = 1+halfwin;
  xMax = M-halfwin;
  yMax = N-halfwin;
  rx = rand(1,num);
  ry = rand(1,num);
  x = round(xMin+rx*(xMax-xMin));
  y = round(yMin+ry*(yMax-yMin));
  for n=1:num
    xn=x(n);
    yn=y(n);
    region=img(xn+w,yn+w);
    [v,p]=max(region(:));
    x(n)=xn+xx(p);
    y(n)=yn+yy(p);
  end
end
