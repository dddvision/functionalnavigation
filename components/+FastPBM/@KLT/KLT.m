classdef KLT < FastPBM.FastPBMConfig & FastPBM.SparseTracker
  
  properties (Constant = true, GetAccess = private)
    halfwin = 5;
    thresh = 0.92;
    cornerMethod = 'Harris';
  end
  
  properties (GetAccess = private, SetAccess = private)
    camera
    mask
    numLevels
  end
  
  methods (Access = public, Static = true)
    function this = KLT(initialTime, camera)
      this = this@FastPBM.SparseTracker(initialTime);
      
      % store camera handle
      this.camera = camera;
      
      % compile mex file if necessary
      if(this.overwriteMEX||(~exist('mexTrackFeaturesKLT', 'file')))
        if(this.verbose)
          fprintf('\nCompiling mex wrapper for native KLT...');
        end
        userDirectory = pwd;
        hidiDirectory = fullfile(userDirectory, '+hidi');
        cd(fullfile(fileparts(mfilename('fullpath')), 'private'));
        try
          mex(['-I"', userDirectory, '"'], ['-I"', hidiDirectory, '"'], 'mexTrackFeaturesKLT.cpp');
        catch err
          cd(userDirectory);
          error(err.message);
        end
        cd(userDirectory);
      end
    end
  end
  
  methods (Abstract = false, Access = public)
   function refresh(this, x)
      this.camera.refresh(x);
    end
    
    function flag = hasData(this)
      flag = this.camera.hasData();
    end
    
    function n = first(this)
      n = this.camera.first();
    end
    
    function n = last(this)
      n = this.camera.last();
    end
    
    function time = getTime(this, n)
      time = this.camera.getTime(n);
    end

    function [rayA, rayB] = findMatches(this, nodeA, nodeB)
      data = FastPBM.edgeCache(nodeA, nodeB, this);
      rayA = data.rayA;
      rayB = data.rayB;
    end
  
    function data = processNode(this, node)
      img = this.prepareImage(node);
      pyramid = buildPyramid(img, this.numLevels);
      kappa = computeCornerStrength(pyramid{1}.gx, pyramid{1}.gy, 1, this.cornerMethod);
      [x, y] = findPeaks(kappa, this.halfwin, this.maxFeatures);
      pix = [y; x];
      data.pyramid = pyramid; % different from using struct('pyramid', pyramid)
      data.pix = pix;
    end

    function data = processEdge(this, nodeA, nodeB)
      dataA = FastPBM.nodeCache(nodeA, this);
      dataB = FastPBM.nodeCache(nodeB, this);
      
      pyramidA = dataA.pyramid;
      pyramidB = dataB.pyramid;
      xA = dataA.pix(2, :);
      yA = dataA.pix(1, :);
      xB = xA; % TODO: predict feature locations more intelligently
      yB = yA;
      [xB, yB] = TrackFeaturesKLT(pyramidA, xA, yA, pyramidB, xB, yB, this.halfwin, this.thresh);
      
      % keep valid points only
      good = ~(isnan(xB)|isnan(yB));
      xB = xB(good);
      yB = yB(good);
      xA = xA(good);
      yA = yA(good);

      rayA = this.camera.inverseProjection([yA; xA]);
      rayB = this.camera.inverseProjection([yB; xB]);
      data = struct('rayA', rayA, 'rayB', rayB);
    end
    
    % Prepare an image for processing
    %
    % Computes number of pyramid levels
    % Gets an image from the camera
    % Converts to grayscale and normalizes to the range [0,1]
    % Applies NaN mask outside of the projection area
    % Pads the bottom and right sides with NaN based on pyramid levels (does not affect pixel coordinates)
    function img = prepareImage(this, node)
      if(isempty(this.numLevels))
        steps = this.camera.numSteps();
        strides = this.camera.numStrides();
        [stepGrid, strideGrid] = ndgrid(0:(double(steps)-1), 0:(double(strides)-1));
        pix = [strideGrid(:)'; stepGrid(:)'];
        ray = this.camera.inverseProjection(pix);
        this.mask = find(isnan(ray(1, :)));
        pix = [double(strides)-2; double(steps)-1]/2;
        pix = [pix, pix+[1; 0]];
        ray = this.camera.inverseProjection(pix);
        angularSpacing = acos(dot(ray(:, 1), ray(:, 2)));
        maxPix = this.maxSearch/angularSpacing;
        this.numLevels = uint32(1+ceil(log2(maxPix/this.halfwin)));
      end
      img = this.camera.getImageDouble(node, uint32(0), uint8(0)); % process red only for speed
      img(this.mask) = NaN;     
      multiple = 2^(this.numLevels-1);
      [M, N] = size(img);
      Mpad = multiple-mod(M, multiple);
      Npad = multiple-mod(N, multiple);
      if((Mpad>0)||(Npad>0))
        img(M+Mpad, N+Npad) = 0; % allocates memory for padded image
      end
      if(Mpad>0)
        img((M+1):(M+Mpad), :) = NaN;
      end  
      if(Npad>0)
        img(:, (N+1):(N+Npad)) = NaN;
      end
    end
  end
  
end

% Finds locations of features in the second image based on their locations in the first image
%
% @param[in]     pyramidA pyramid structure built from the first frame
% @param[in]     xA       one-based sub-pixel rows of patch centers in first frame
% @param[in]     yA       one-based sub-pixel columns of patch centers in first frame
% @param[in]     pyramidB pyramid structure built from the second frame
% @param[in,out] xB       one-based estimated sub-pixel rows of patch centers in second frame
% @param[in,out] yB       one-based estimated sub-pixel columns of patch centers in second frame
% @param[in]     halfwin  half window size over which to track
% @param[in]     thresh   matching threshold below which features will not be matched
function [xB, yB] = TrackFeaturesKLT(pyramidA, xA, yA, pyramidB, xB, yB, halfwin, thresh)
  xAref=xA-1;
  yAref=yA-1;
  xB=xB-1;
  yB=yB-1;
  
  numLevels = length(pyramidA);
  for level = numLevels:-1:1
    imageA = pyramidA{level}.f;
    gxA = pyramidA{level}.gx;
    gyA = pyramidA{level}.gy;

    imageB = pyramidB{level}.f;
    gxB = pyramidB{level}.gx;
    gyB = pyramidB{level}.gy;

    if(level>1)
      scale = 2^(level-1);
      xA = xAref/scale;
      yA = yAref/scale;
      xB = xB/scale;
      yB = yB/scale;
    else
      xA = xAref;
      yA = yAref;
    end

    [xB, yB] = mexTrackFeaturesKLT(imageA, gxA, gyA, xA, yA, imageB, gxB, gyB, xB, yB, halfwin, thresh);
    
    if(level>1)
      xB = xB*scale;
      yB = yB*scale;
    end
  end
  
  xB=xB+1;
  yB=yB+1;
end

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
  [xx,yy] = ndgrid(w, w);
  xMin = 1+halfwin;
  yMin = 1+halfwin;
  xMax = M-halfwin;
  yMax = N-halfwin;
  rx = (rand(1, num)+rand(1, num))/2; % random, centrally weighted, in [0,1]
  ry = (rand(1, num)+rand(1, num))/2;
  x = round(xMin+rx*(xMax-xMin));
  y = round(yMin+ry*(yMax-yMin));
  for n = 1:num
    xn = x(n);
    yn = y(n);
    region = img(xn+w, yn+w);
    [v, p] = max(region(:));
    x(n) = xn+xx(p);
    y(n) = yn+yy(p);
  end
end

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
  win = (2*halfwin+1)*[1, 1];

  % formulate the gradient products
  gxx = gi.*gi;
  gyy = gj.*gj;
  gxy = gi.*gj;

  % perform gaussian smoothing over a window
  if(halfwin>=1)
    mask = fspecial('gaussian', win, halfwin/4);
    gxx = filter2(mask, gxx);
    gyy = filter2(mask, gyy);
    gxy = filter2(mask, gxy);
  end
    
  % calculate corner intensity
  switch(method)
    case 'Harris'
      kappa = Harris(gxx, gyy, gxy);
    case 'EigMin'
      kappa = EigMin(gxx, gyy, gxy);
    case 'EigBalance'
      kappa = EigBalance(gxx, gyy, gxy);
    otherwise
      error('Unrecognized corner computation method');
  end
end

% The corner detector of Harris and Stephens
function val = Harris(xx, yy, xy)
  val = (xx.*yy-xy.*xy)./(xx+yy+eps);
end

% Calculates the minimum (and maximum) eigenvalues
function lam1 = EigMin(xx, yy, xy)
  dif = xx-yy;
  a = (xx+yy)/2;
  b = sqrt(dif.*dif+4*xy.*xy)/2;
  lam1 = a-b;
%  lam2 = a+b;
end

% Finds corners with balanced eigenvalues
function val = EigBalance(xx, yy, xy)
  pow = 1.5;
  val = (xx.*yy-xy.*xy)./((xx+yy+eps).^pow);
end

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
function pyramid = buildPyramid(f, numLevels)
  pyramid = cell(numLevels, 1);
  for level = 1:numLevels
    if(level>1)
      f = imageReduce(f);
    end
    [gx, gy] = imageGradient(f);
    pyramid{level}.f = f;
    pyramid{level}.gx = gx;
    pyramid{level}.gy = gy;
  end
end

% Computes the gradient using the central difference formula
function [gx, gy] = imageGradient(f)
  gx = diff(f, 1, 1);
  gy = diff(f, 1, 2);
  gx = ([gx(1, :); gx]+[gx; gx(end, :)])/2;
  gy = ([gy(:, 1), gy]+[gy, gy(:, end)])/2;
end

% Reduces image to half resolution
function x = imageReduce(x)
  [m,n] = size(x);
  if(mod(m,2)||mod(n,2))
    error('Image height and width must be multiples of 2');
  end
  x = x(1:2:end,:)+x(2:2:end, :);
  x = x(:,1:2:end)+x(:, 2:2:end);
  x = x/4;
end
