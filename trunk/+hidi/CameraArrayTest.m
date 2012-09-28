% Assumes that the general Sensor interface has already been tested
classdef CameraArrayTest
  
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
    function this = CameraArrayTest(cam)
      assert(isa(cam, 'hidi.CameraArray'));
      
      if(~cam.hasData())
        return;
      end
      nb = cam.last();
      
      testCameraArrayProjection(cam, nb);
      testCameraArrayProjectionRoundTrip(cam, nb);
    end
  end
  
end
    
function testCameraArrayProjection(cam, nb)
  figure(hidi.CameraArrayTest.figureHandle());

  % test each view 
  for view = ((uint32(1):cam.numViews())-uint32(1))

    % get an image
    gray = cam.getImage(nb, view);

    % convert to grayscale
    switch( interpretLayers(cam, view) )
    case {'rgb', 'rgbi'}
      gray = double(rgb2gray(gray(:, :, 1:3)))/255;
     case {'hsv', 'hsvi'}
      gray = double(gray(:, :, 3))/255;
     otherwise
      gray = double(gray)/255;
    end

    % show original image
    imshow(gray, 'Parent', subplot(3, 3, 1));

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
      mag(abs(mag)<eps) = NaN;
      c1 = c1./mag;
      c2 = c2./mag;
      c3 = c3./mag;
      rays = [c1(:)';c2(:)';c3(:)'];

      % project these rays to the given camera
      pix = cam.projection(rays, nb, view);

      % grab pixels using bilinear interpolation
      bad = isnan(pix(1, :))|isnan(pix(2, :));
      good = ~bad;
      newImage = zeros(HEIGHT, WIDTH);
      newImage(bad) = NaN;
      newImage(good) = interp2(gray, pix(1, good)+1, pix(2, good)+1, '*linear', NaN);

      % display the reprojected image
      imshow(newImage, 'Parent', subplot(3, 3, 2));
      title('Test Camera Array Projection');
      drawnow;
      pause(0.1);
    end
  end 
end

function testCameraArrayProjectionRoundTrip(cam, nb)
  figure(hidi.CameraArrayTest.figureHandle());

  % test each view
  for view = ((uint32(1):cam.numViews())-uint32(1))

    % get an image
    img = cam.getImage(nb, view);

    % show image
    imshow(img, 'Parent', subplot(3, 3, 3));

    % get image size
    HEIGHT = size(img, 1);
    WIDTH = size(img, 2);

    % enumerate pixels
    [ii, jj] = ndgrid((1:HEIGHT)-1, (1:WIDTH)-1);
    pix = [jj(:)';ii(:)'];

    % create ray vectors from pixels
    ray = cam.inverseProjection(pix, nb, view);
    c1 = reshape(ray(1, :), [HEIGHT, WIDTH]);
    c2 = reshape(ray(2, :), [HEIGHT, WIDTH]);
    c3 = reshape(ray(3, :), [HEIGHT, WIDTH]);

    % show the ray vector components
    imshow(c1, [], 'Parent', subplot(3, 3, 4));
    imshow(c2, [], 'Parent', subplot(3, 3, 5));
    title('Test Camera Array Inverse Projection');
    imshow(c3, [], 'Parent', subplot(3, 3, 6));
    
    % reproject the rays to pixel coordinates
    pixout = cam.projection(ray, nb, view);
    iout = reshape(pixout(2, :), [HEIGHT, WIDTH]);
    jout = reshape(pixout(1, :), [HEIGHT, WIDTH]);

    % calculate pixel coordinate differences
    idiff = abs(iout-ii);
    jdiff = abs(jout-jj);

    % display differences
    imshow(10000*idiff+0.5, 'Parent', subplot(3, 3, 7));
    imshow(10000*jdiff+0.5, 'Parent', subplot(3, 3, 8));
    title('Test Camera Array Projection Round Trip (image area should be gray)');
  end
end
