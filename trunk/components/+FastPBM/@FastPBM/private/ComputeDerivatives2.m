% Computes the gradients of one or two arrays
% Uses a 4-element finite difference approximation
% Optionally computes the corresponding difference between arrays
% Removes one-pixel borders that do not make sense by convolution
%
%    y = array (m-by-n)
% yref = reference array (m-by-n)
%   fi = row gradient (m-by-n)
%   fj = column gradient (m-by-n)
%   ft = corresponding array differences (m-by-n)

function [fi,fj,ft]=ComputeDerivatives2(y,yref)

  if (size(y,3)~=1)
    error('input must be a 2-dimensional array');
  end

  if nargin==2
    if (size(y,1) ~= size(yref,1)) || (size(y,2) ~= size(yref,2))
      error('input arrays must be of equal size');
    end
    if (size(yref,3)~=1)
      error('input must be a 2-dimensional array');
    end
  end

  imask=[
    0  0  0;
    0 -1 -1;
    0  1  1]/2;

  jmask=[
    0  0  0;
    0 -1  1;
    0 -1  1]/2;

  fi=filter2(imask,y);
  fj=filter2(jmask,y);

  fi=RemoveBorders(fi,1);
  fj=RemoveBorders(fj,1);

  if nargin==2
    tmask=[
      0  0  0;
      0  1  1;
      0  1  1]/4;
    ft=filter2(tmask,y)+filter2(-tmask,yref);
    ft=RemoveBorders(ft,1);
  else
    ft=[];
  end

end
