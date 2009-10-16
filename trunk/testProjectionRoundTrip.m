function testProjectionRoundTrip
  % close figure windows
  close all;
  drawnow;

  % get camera object from a named data container
  cam=getCameraObject('middleburyData');

  % find out which images are available
  [ka,kb]=domain(cam);

  % get an image
  img=getImage(cam,kb);
  
  % show image
  figure(1);
  imshow(img);
  
  % get image size
  HEIGHT=size(img,1);
  WIDTH=size(img,2);
  
  % enumerate pixels
  [jj,ii]=meshgrid((1:WIDTH)-1,(1:HEIGHT)-1);
  pix=[jj(:)';ii(:)'];
  
  % create ray vectors from pixels
  ray=inverseProjection(cam,pix);
  c1=reshape(ray(1,:),[HEIGHT,WIDTH]);
  c2=reshape(ray(2,:),[HEIGHT,WIDTH]);
  c3=reshape(ray(3,:),[HEIGHT,WIDTH]);
  
  % show the ray vector components
  figure(2);
  imshow([c1,c2,c3],[]);

  % reproject the rays to pixel coordinates
  pixout=projection(cam,ray);
  iout=reshape(pixout(2,:),[HEIGHT,WIDTH]);
  jout=reshape(pixout(1,:),[HEIGHT,WIDTH]);
  
  % calculate pixel coordinate differences
  idiff=abs(iout-ii);
  jdiff=abs(jout-jj);
  
  % display differences
  figure(3);
  imshow(1000*[idiff,jdiff]+0.5);
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
