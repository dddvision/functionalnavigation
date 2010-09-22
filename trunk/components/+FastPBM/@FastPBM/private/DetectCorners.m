% Detects corner features given image gradients
%
% @param[in] gi      image gradient along the contiguous dimension
% @param[in] gj      image gradient along the non-contiguous dimension
% @param[in] halfwin radius in pixels to use for a smoothing window
% @param[in] method  method to use to compute corner feature ('HarrisCorner', 'Eig2x2', 'EigBalance')
% @return            corner strength image
%
% NOTES
% All methods are based on the following symmetric 2x2 matrix consisting of sums of local image gradients
%   [xx xy]
%   [xy yy]
function kappa=DetectCorners(gi,gj,halfwin,method)

  % window to use for smoothing
  win=(2*halfwin+1)*[1,1];

  % formulate the gradient products
  gxx=gi.*gi;
  gyy=gj.*gj;
  gxy=gi.*gj;

  % perform smoothing or local sum
  xx=Smooth2(gxx,win,halfwin/4);
  yy=Smooth2(gyy,win,halfwin/4);
  xy=Smooth2(gxy,win,halfwin/4);

  % calculate corner intensity
  switch(method)
    case 'HarrisCorner'
      kappa=HarrisCorner(xx,yy,xy);
    case 'Eig2x2'
      kappa=Eig2x2(xx,yy,xy);
    case 'EigBalance'
      kappa=EigBalance(xx,yy,xy);
    otherwise
      error('Unrecognized corner computation method');
  end
end

% Performs gaussian smoothing over a window
function OUT=Smooth2(I,win,sig)
  M=fspecial('gaussian',win,sig);
  OUT=filter2(M,I);
end

% The corner detector of Harris and Stephens
function val=HarrisCorner(xx,yy,xy)
  val=(xx.*yy-xy.*xy)./(xx+yy+eps);
end

% Calculates the minimum (and maximum) eigenvalues
function [lam1,lam2]=Eig2x2(xx,yy,xy)
  dif=xx-yy;
  a=(xx+yy)/2;
  b=sqrt(dif.*dif+4*xy.*xy)/2;
  lam1=a-b;
  if(nargout>1)
    lam2=a+b;
  end
end

% Finds corners with balanced eigenvalues
function val=EigBalance(xx,yy,xy)
  pow=1.5;
  val=(xx.*yy-xy.*xy)./((xx+yy+eps).^pow);
end
