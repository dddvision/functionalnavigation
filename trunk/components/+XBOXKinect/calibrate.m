function calibrate
  % check MATLAB version
  try
    matlabVersionString = version('-release');
    matlabVersion = str2double(matlabVersionString(1:4));
  catch err
    error('%s. Implement MATLAB Solution ID 1-5JUPSQ and restart MATLAB', err.message);
  end
  if(matlabVersion<2009)
    error('\nRequires MATLAB version 2009a or greater');
  end

  % initialize the default pseudorandom number generator
  if(matlabVersion<2010)
    RandStream.getDefaultStream.reset(); %#ok supports legacy versions
  else
    RandStream.getGlobalStream.reset();
  end

  % close figures and clear everything except breakpoints
  breakpoints = dbstatus('-completenames');
  save('temp.mat', 'breakpoints');
  close('all');
  clear('classes');
  load('temp.mat');
  dbstop(breakpoints);

  % add component repository to the path
  componentPath = fullfile(fileparts(mfilename('fullpath')), 'components');
  if(isempty(strfind(path, componentPath)))
    addpath(componentPath);
    fprintf('\naddpath = %s', componentPath);
  end

  % set the warning state
  warning('on', 'all');
  warning('off', 'MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

  dc = hidi.DataContainer.create('XBOXKinect', hidi.getCurrentTime());

%  maccam = dc.getSensor(uint32(0));
  kinect = dc.getSensor(uint32(1));

  for n = uint32(799)
    disp(n);    
    
    % rotate and translate those points
    [R2, T2] = ndgrid(-0.04:0.001:0.04, -0.08:0.002:0.08);
%     [I, J] = size(R2);
%     penalty = zeros(I, J);
%     for i = 1:I
%       for j = 1:J
%         theta = [0; R2(i, j); 0; 0; T2(i, j); 0];
%         penalty(i,j) = objective(theta, kinect, n, false);
%       end
%     end

    load('0.mat')
    H0=penalty;
    load('799.mat')
    H799=penalty;
%     load('1497.mat')
%     H1497=penalty;
%     load('1548.mat')
%     H1548=penalty;
    penalty=sqrt(H0.*H799);
    
%     figure;
%     surf(R2, T2, H0);
%     shading('flat');
%     
%     figure;
%     surf(R2, T2, H799);
%     shading('flat');
    
    figure;
    surf(R2, T2, penalty);
    shading('flat');
    
    objective(zeros(6, 1), kinect, n, true)
    
    [iMin, jMin] = find(penalty==min(penalty(:)), 1, 'first');
    theta = [0; R2(iMin, jMin); 0; 0; T2(iMin, jMin); 0];
    objective(theta, kinect, n, true)
  end
end

function cost = objective(theta, kinect, n, displayFlag)
  persistent steps strides visualEdge rgbDist r g b z1 z2 z3
  
  if(isempty(rgbDist))
    
    steps = kinect.numSteps();
    strides = kinect.numStrides();
    depth = kinect.getDepth(n);
   
    % find all depth edge pixels
    depthInv = 1./depth;
    nanEdge = ~isnan(depthInv); % not nan pixel
    nanEdge(:, 2:end) = nanEdge(:, 2:end)&(~nanEdge(:, 1:(end-1))); % and pixel to the left is nan
    depthInvMin = LocalMIN(depthInv, [3, 3]);
    depthInvMax = LocalMAX(depthInv, [3, 3]);
    depthStep = (depthInv-depthInvMax+abs(depthInvMin-depthInv))>0.02;
    depthEdge = RemoveBorders(nanEdge|depthStep, 1);
    
    % place depth edges in the world using p1, p2, p3
    [pix2, pix1] = find(depthEdge);
    ind = sub2ind([steps, strides], pix2, pix1);
    pix = [pix1'; pix2'];
    rayLidar = kinect.depthInverseProjection(pix, uint32(1));
    z1 = rayLidar(1, :).*depth(ind)';
    z2 = rayLidar(2, :).*depth(ind)';
    z3 = rayLidar(3, :).*depth(ind)';
    
    % process visual image
    rgb = kinect.getImage(n);
    r = rgb(:, :, 1);
    g = rgb(:, :, 2);
    b = rgb(:, :, 3);
    v = rgb2gray(rgb);

    % find all edges in rgb space using central differences
    opt = {'canny', 0.1, sqrt(2)};
    visualEdge = ...
      edge(r, opt{:})|...
      edge(g, opt{:})|...
      edge(b, opt{:})|...
      edge(v, opt{:});

    % apply BWDIST to create edge match metric    
    rgbDist = bwdist(visualEdge);
  end

  R = theta(1:3);
  T = theta(4:6);
  zz = Euler2Matrix(R)*([z1+T(1); z2+T(2); z3+T(3)]);
  depthCamera = sqrt(zz(1, :).^2+zz(2, :).^2+zz(3, :).^2);
  rayCamera = zz./([1; 1; 1]*max(depthCamera, eps));

  % reproject depth edges to the image space
  pixCamera = kinect.imageProjection(rayCamera, uint32(1));
  outside = isnan(pixCamera(1, :));
  pixCamera = pixCamera(:, ~outside);
  pixCamera = round(pixCamera+1);
  ind = sub2ind([steps, strides], pixCamera(2, :), pixCamera(1, :));

  cost = sum(rgbDist(ind))+sum(outside)*mean(rgbDist(ind));
  
  if(displayFlag)
    mask = false(steps, strides);
    mask(ind) = true;
    mask = imdilate(mask, ones(3));
    ind = find(mask);
    rCopy = r;
    gCopy = g;
    bCopy = b;
    rCopy(ind) = uint8(255);
    gCopy(ind) = uint8(0);
    bCopy(ind) = uint8(0);
    rgbMatch = cat(3, rCopy, gCopy, bCopy);

    figure;
    imshow(visualEdge);
    figure;
    imshow(rgbMatch);
  end
end
