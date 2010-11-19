% Computes corner strength given image gradients
%
% @param[in] gi      image gradient along the contiguous dimension
% @param[in] gj      image gradient along the non-contiguous dimension
% @param[in] halfwin radius in pixels to use for a smoothing window
% @param[in] method  method to use to compute corner feature ('Harris', 'EigMin', 'EigBalance')
% @return            corner strength image
%
% NOTES
% All methods are based on the following symmetric 2x2 matrix consisting of sums of local image gradients
%   [xx xy]
%   [xy yy]
function kappa = computeCornerStrength(gi, gj, halfwin, method)

  % window to use for smoothing
  win=(2*halfwin+1)*[1,1];

  % formulate the gradient products
  gxx=gi.*gi;
  gyy=gj.*gj;
  gxy=gi.*gj;

  % perform gaussian smoothing over a window
  if(halfwin>=1)
    mask=fspecial('gaussian',win,halfwin/4);
    gxx=filter2(mask,gxx);
    gyy=filter2(mask,gyy);
    gxy=filter2(mask,gxy);
  end
    
  % calculate corner intensity
  switch(method)
    case 'Harris'
      kappa=Harris(gxx,gyy,gxy);
    case 'EigMin'
      kappa=EigMin(gxx,gyy,gxy);
    case 'EigBalance'
      kappa=EigBalance(gxx,gyy,gxy);
    otherwise
      error('Unrecognized corner computation method');
  end
end

% The corner detector of Harris and Stephens
function val=Harris(xx,yy,xy)
  val=(xx.*yy-xy.*xy)./(xx+yy+eps);
end

% Calculates the minimum (and maximum) eigenvalues
function lam1=EigMin(xx,yy,xy)
  dif=xx-yy;
  a=(xx+yy)/2;
  b=sqrt(dif.*dif+4*xy.*xy)/2;
  lam1=a-b;
%  lam2=a+b;
end

% Finds corners with balanced eigenvalues
function val=EigBalance(xx,yy,xy)
  pow=1.5;
  val=(xx.*yy-xy.*xy)./((xx+yy+eps).^pow);
end
