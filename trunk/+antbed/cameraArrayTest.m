function cameraArrayTest(cam, trajectory)
  assert(isa(cam, 'antbed.CameraArray'));
  testCameraArrayProjection(cam, trajectory);
  testCameraArrayProjectionRoundTrip(cam, trajectory);
end

function testCameraArrayProjection(cam, trajectory)
  % find out which images are available
  cam.refresh(trajectory);
  if(~cam.hasData())
    error('camera is not ready');
  end
  na = cam.first();
  nb = cam.last();
  assert(isa(na, 'uint32'));
  assert(isa(nb, 'uint32'));
  
  for view = 1:cam.numViews();

    % get an image
    img = cam.getImage(nb, view);

    % convert to grayscale
    switch cam.interpretLayers(view)
      case 'rgb'
        gray = double(rgb2gray(img))/255;
      case 'y'
        gray = double(img)/255;
      otherwise
        error('unhandled image type');
    end

    % show original image
    figure;
    imshow(gray);
    drawnow;

    % set parameters for your desired camera
    HEIGHT = 200;
    WIDTH = 300;
    CENTER_VERT = (HEIGHT+1)/2;
    CENTER_HORZ = (WIDTH+1)/2;

    fig = figure;
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
      figure(fig);
      imshow(newImage);
      title('Test Camera Array Projection');
      drawnow;
      pause(0.1);
    end
  end 
end

function testCameraArrayProjectionRoundTrip(cam, trajectory)
  % find out which images are available
  cam.refresh(trajectory);
  if(~cam.hasData())
    error('camera is not ready');
  end
  na = cam.first();
  nb = cam.last();
  assert(isa(na, 'uint32'));
  assert(isa(nb, 'uint32'));

  for view = 1:cam.numViews();

    % get an image
    img = cam.getImage(nb, view);

    % show image
    figure;
    imshow(img);
    drawnow;

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
    figure;
    imshow([c1, c2, c3], []);
    title('Test Camera Array Inverse Projection');
    drawnow;

    % reproject the rays to pixel coordinates
    pixout = cam.projection(ray, nb, view);
    iout = reshape(pixout(2, :), [HEIGHT, WIDTH]);
    jout = reshape(pixout(1, :), [HEIGHT, WIDTH]);

    % calculate pixel coordinate differences
    idiff = abs(iout-ii);
    jdiff = abs(jout-jj);

    % display differences
    figure;
    imshow(1000*[idiff, jdiff]+0.5);
    title('Test Camera Array Projection Round Trip (image area should be gray)');
    drawnow;
  end
end
