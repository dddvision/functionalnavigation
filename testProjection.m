function testProjection
  % close figure windows
  close all;
  drawnow;

  % get camera object from a named data container
  cam=getCameraObject('middleburyData');

  % find out which images are available
  [ka,kb]=domain(cam);

  % get an image
  img=getImage(cam,kb);

  % convert to grayscale
  switch interpretLayers(cam)
    case 'rgb'
      gray=double(rgb2gray(img))/255;
    case 'y'
      gray=double(img)/255;
    otherwise
      error('unhandled image type');
  end
  
  % show original image
  figure(1);
  imshow(gray);

  % set parameters for your desired camera
  HEIGHT=1110;
  WIDTH=1390;
  CENTER_VERT=(HEIGHT+1)/2;
  CENTER_HORZ=(WIDTH+1)/2;
  
  for FOCAL=(WIDTH-1)/2*(1:-0.1:0.1)
    % create rays corresponding to your desired camera
    [c2,c3]=meshgrid((1:WIDTH)-CENTER_HORZ,(1:HEIGHT)-CENTER_VERT);
    c1=repmat(FOCAL,[HEIGHT,WIDTH]);
    mag=sqrt(c1.*c1+c2.*c2+c3.*c3);
    mag(abs(mag)<eps)=NaN;
    c1=c1./mag;
    c2=c2./mag;
    c3=c3./mag;

    % project these rays to the given camera
    pix=projection(cam,[c1(:)';c2(:)';c3(:)']);

    % grab pixels using bilinear interpolation
    newPixels=interp2(gray,pix(1,:)+1,pix(2,:)+1,'*linear',NaN);
    newImage=reshape(newPixels,[HEIGHT,WIDTH]);
    
    % display the reprojected image
    figure(2);
    imshow(newImage);
    drawnow;
  end
end


function cam=getCameraObject(dataContainerString)
  % add the components directory to the path
  warning('off');
  addpath(path,fullfile(fileparts(which('main')),'components'));
  warning('on');

  % get the data package
  allData=eval([dataContainerString,'.',dataContainerString]);

  % list available cameras
  list=listSensors(allData,'camera');

  % get and lock the first camera
  cam=getSensor(allData,list(1));
  lock(cam);
end
