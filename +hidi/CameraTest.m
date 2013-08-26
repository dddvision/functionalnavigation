% Assumes that the general Sensor interface has already been tested
classdef CameraTest
  
  methods (Access = private, Static = true)
    function handle = figureHandle
      persistent h
      if(isempty(h))
        h = figure;
        set(h, 'Name', 'Camera projection tests');
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
    img = cam.getImageDouble(nb, layer, uint8(0));
    img = reshape(img, cam.numStrides(), cam.numSteps())';

    % show original image
    imshow(img, 'Parent', subplot(3, 3, 1));

    % set parameters for your desired camera
    HEIGHT = 200;
    WIDTH = 300;
    CENTER_VERT = (HEIGHT+1)/2;
    CENTER_HORZ = (WIDTH+1)/2;

    for FOCAL = (WIDTH-1)/2*(1:-0.1:0.1)
      % create rays corresponding to your desired camera
      [c3, c2] = ndgrid((1:HEIGHT)-CENTER_VERT, (1:WIDTH)-CENTER_HORZ);
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
    img = cam.getImageDouble(nb, layer, uint8(0));
    img = reshape(img, cam.numStrides(), cam.numSteps())';

    % show image
    imshow(img, 'Parent', subplot(3, 3, 3));

    % get image size
    HEIGHT = size(img, 1);
    WIDTH = size(img, 2);

    % enumerate pixels
    [strides, steps] = ndgrid((1:HEIGHT)-1, (1:WIDTH)-1);

    % create ray vectors from pixels
    [c1, c2, c3] = cam.inverseProjection(strides, steps);
    if((size(c1, 1)~=HEIGHT)||(size(c1, 2)~=WIDTH)||(size(c2, 1)~=HEIGHT)||(size(c2, 2)~=WIDTH)||...
      (size(c3, 1)~=HEIGHT)||(size(c3, 2)~=WIDTH))
      error('CameraTest: inverse projection function output dimensions do not match input dimensions');
    end

    % show the ray vector components
    imshow(c1, [], 'Parent', subplot(3, 3, 4));
    imshow(c2, [], 'Parent', subplot(3, 3, 5));
    title('Test Camera Array Inverse Projection');
    imshow(c3, [], 'Parent', subplot(3, 3, 6));

    % reproject the rays to pixel coordinates
    [jout, iout] = cam.projection(c1, c2, c3);
    if((size(jout, 1)~=HEIGHT)||(size(jout, 2)~=WIDTH)||(size(iout, 1)~=HEIGHT)||(size(iout, 2)~=WIDTH))
      error('CameraTest: projection function output dimensions do not match input dimensions');
    end

    % calculate pixel coordinate differences
    idiff = abs(iout-strides);
    jdiff = abs(jout-steps);

    % display differences
    imshow(10000*idiff+0.5, 'Parent', subplot(3, 3, 7));
    imshow(10000*jdiff+0.5, 'Parent', subplot(3, 3, 8));
    title('Test Camera Array Projection Round Trip (image area should be gray)');
  end
end
