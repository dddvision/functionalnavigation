% Assumes that the general Sensor interface has already been tested
classdef CameraTest
  
  methods (Access = private, Static = true)
    function handle = figureHandle
      persistent h
      if(isempty(h))
        h = figure;
        set(h, 'Name', 'Camera Projection Tests');
      end
      handle = h;
    end        
  end
  
  methods (Access = public, Static = true)
    function this = CameraTest(cam)
      assert(isa(cam, 'hidi.Camera'));
      
      if(~cam.hasData())
        return;
      end
      nb = cam.last();
      
      testCameraProjection(cam, nb);
      testCameraProjectionRoundTrip(cam, nb);
    end
  end
  
end
    
function testCameraProjection(cam, nb)
  figure(hidi.CameraTest.figureHandle());

  layers = cam.interpretLayers();
  assert(isa(layers, 'char'));
  
  for layer = uint32((1:numel(layers))-1)
    % get an image
    img = cam.getImageDouble(nb, layer, zeros(0, 1));

    % get image size
    numStrides = cam.numStrides();
    numSteps = cam.numSteps();
    
    % reshape image
    img = reshape(img, numSteps, numStrides);
    
    % show original image
    imshow(img, 'Parent', subplot(3, 3, 1));

    % set parameters for your desired camera
    HEIGHT = 200.0;
    WIDTH = 300.0;
    CENTER_VERT = (HEIGHT+1.0)/2.0;
    CENTER_HORZ = (WIDTH+1.0)/2.0;

    for FOCAL = (WIDTH-1.0)/2.0*(1.0:-0.1:0.1)
      % create rays corresponding to your desired camera
      [c3, c2] = ndgrid((1.0:HEIGHT)-CENTER_VERT, (1.0:WIDTH)-CENTER_HORZ);
      c1 = repmat(FOCAL, [HEIGHT, WIDTH]);
      mag = sqrt(c1.*c1+c2.*c2+c3.*c3);
      mag(abs(mag)<eps) = nan;
      c1 = c1./mag;
      c2 = c2./mag;
      c3 = c3./mag;

      % project these rays to the given camera
      [strides, steps] = cam.projection(c1, c2, c3);
      if((size(strides, 1)~=HEIGHT)||(size(strides, 2)~=WIDTH)||(size(steps, 1)~=HEIGHT)||(size(steps, 2)~=WIDTH))
        error('CameraTest: projection function output dimensions do not match input dimensions');
      end

      % grab pixels using bilinear interpolation
      bad = isnan(strides)|isnan(steps);
      good = ~bad;
      newImage = zeros(HEIGHT, WIDTH);
      newImage(bad) = nan;
      newImage(good) = interp2(img, strides(good)+1, steps(good)+1, '*linear', nan);

      % display the reprojected image
      imshow(newImage, 'Parent', subplot(3, 3, 2));
      title('Test Camera Array Projection');
      drawnow;
      pause(0.1);
    end
  end
end

function testCameraProjectionRoundTrip(cam, nb)
  figure(hidi.CameraTest.figureHandle());

  layers = cam.interpretLayers();
  assert(isa(layers, 'char'));
  
  for layer = uint32((1:numel(layers))-1)
  
    % get an image
    img = cam.getImageDouble(nb, layer, zeros(0, 1));

    % get image size
    numStrides = cam.numStrides();
    numSteps = cam.numSteps();
    
    % reshape image
    img = reshape(img, numSteps, numStrides);
    
    % show image
    imshow(img, 'Parent', subplot(3, 3, 3));

    % enumerate pixels
    [steps, strides] = ndgrid((1:double(numSteps))-1, (1:double(numStrides))-1);

    % create ray vectors from pixels
    [c1, c2, c3] = cam.inverseProjection(strides, steps);
    if((size(c1, 1)~=numSteps)||(size(c1, 2)~=numStrides)||(size(c2, 1)~=numSteps)||(size(c2, 2)~=numStrides)||...
      (size(c3, 1)~=numSteps)||(size(c3, 2)~=numStrides))
      error('CameraTest: inverse projection function output dimensions do not match input dimensions');
    end

    % show the ray vector components
    imshow(c1, [], 'Parent', subplot(3, 3, 4));
    imshow(c2, [], 'Parent', subplot(3, 3, 5));
    title('Test Camera Array Inverse Projection');
    imshow(c3, [], 'Parent', subplot(3, 3, 6));

    % reproject the rays to pixel coordinates
    [jout, iout] = cam.projection(c1, c2, c3);
    if((size(jout, 1)~=numSteps)||(size(jout, 2)~=numStrides)||(size(iout, 1)~=numSteps)||(size(iout, 2)~=numStrides))
      error('CameraTest: projection function output dimensions do not match input dimensions');
    end

    % calculate pixel coordinate differences
    idiff = abs(iout-steps);
    jdiff = abs(jout-strides);

    % display differences
    imshow(10000*idiff+0.5, 'Parent', subplot(3, 3, 7));
    imshow(10000*jdiff+0.5, 'Parent', subplot(3, 3, 8));
    title('Test Camera Array Projection Round Trip (image area should be gray)');
  end
end
