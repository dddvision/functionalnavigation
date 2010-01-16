% Testbed for TOMMAS components
%
% INPUT
% componentString = name of the package containing the component, string
function testComponent(componentString)
  component=unwrapComponent(componentString);
  switch(component.baseClass)
    case 'dataContainer'
      testDataContainer(component);
    case 'dynamicModel'
      testDynamicModel(component);
    case 'measure'
      testMeasure(component);
    case 'optimizer'
      testOptimizer(component);
    otherwise
      warning('testComponent:exception','unrecognized component type');
  end      
end

function testDataContainer(container)
  % Unit tests
  list=listSensors(container,'cameraArray');
  for k=1:numel(list)
    u=getSensor(container,list(k));
    testCameraArrayProjection(u);
    testCameraArrayProjectionRoundTrip(u);
  end
  
  % Navigation performance tests
  if hasReferenceTrajectory(container)
    x=getReferenceTrajectory(container);
    testReferenceTrajectory(x);
    list=listSensors(container,'gps');
    for k=1:numel(list)
      u=getSensor(container,list(k));
      testGPSaccuracy(u,x);
    end
  end
end

function testReferenceTrajectory(x)
  [a,b]=domain(x);
  t=a:b;
  [p,q]=evaluate(x,t);
  figure;
  plot3(p(1,:),p(2,:),p(3,:),'b.');
  figure;
  plot3(q(2,:),q(3,:),q(4,:));
end

function testCameraArrayProjection(cam)
  % find out which images are available
  if(~refresh(cam))
    error('camera is not ready');
  end
  ka=first(cam);
  kb=last(cam);
  assert(isa(ka,'uint32'));
  assert(isa(kb,'uint32'));
  
  for view=1:numViews(cam);

    % get an image
    img=getImage(cam,kb,view);

    % convert to grayscale
    switch interpretLayers(cam,view)
      case 'rgb'
        gray=double(rgb2gray(img))/255;
      case 'y'
        gray=double(img)/255;
      otherwise
        error('unhandled image type');
    end

    % show original image
    figure;
    imshow(gray);
    drawnow;

    % set parameters for your desired camera
    HEIGHT=200;
    WIDTH=300;
    CENTER_VERT=(HEIGHT+1)/2;
    CENTER_HORZ=(WIDTH+1)/2;

    fig=figure;
    for FOCAL=(WIDTH-1)/2*(1:-0.1:0.1)
      % create rays corresponding to your desired camera
      [c3,c2]=ndgrid((1:HEIGHT)-CENTER_VERT,(1:WIDTH)-CENTER_HORZ);
      c1=repmat(FOCAL,[HEIGHT,WIDTH]);
      mag=sqrt(c1.*c1+c2.*c2+c3.*c3);
      mag(abs(mag)<eps)=NaN;
      c1=c1./mag;
      c2=c2./mag;
      c3=c3./mag;
      rays=[c1(:)';c2(:)';c3(:)'];

      % project these rays to the given camera
      pix=projection(cam,rays,kb,view);

      % grab pixels using bilinear interpolation
      bad=isnan(pix(1,:))|isnan(pix(2,:));
      good=~bad;
      newImage=zeros(HEIGHT,WIDTH);
      newImage(bad)=NaN;
      newImage(good)=interp2(gray,pix(1,good)+1,pix(2,good)+1,'*linear',NaN);

      % display the reprojected image
      figure(fig);
      imshow(newImage);
      title('Test Camera Array Projection');
      drawnow;
    end
  end 
end

function testCameraArrayProjectionRoundTrip(cam)
  % find out which images are available
  if(~refresh(cam))
    error('camera is not ready');
  end
  ka=first(cam);
  kb=last(cam);
  assert(isa(ka,'uint32'));
  assert(isa(kb,'uint32'));

  for view=1:numViews(cam);

    % get an image
    img=getImage(cam,kb,view);

    % show image
    figure;
    imshow(img);
    drawnow;

    % get image size
    HEIGHT=size(img,1);
    WIDTH=size(img,2);

    % enumerate pixels
    [ii,jj]=ndgrid((1:HEIGHT)-1,(1:WIDTH)-1);
    pix=[jj(:)';ii(:)'];

    % create ray vectors from pixels
    ray=inverseProjection(cam,pix,kb,view);
    c1=reshape(ray(1,:),[HEIGHT,WIDTH]);
    c2=reshape(ray(2,:),[HEIGHT,WIDTH]);
    c3=reshape(ray(3,:),[HEIGHT,WIDTH]);

    % show the ray vector components
    figure;
    imshow([c1,c2,c3],[]);
    title('Test Camera Array Inverse Projection');
    drawnow;

    % reproject the rays to pixel coordinates
    pixout=projection(cam,ray,kb,view);
    iout=reshape(pixout(2,:),[HEIGHT,WIDTH]);
    jout=reshape(pixout(1,:),[HEIGHT,WIDTH]);

    % calculate pixel coordinate differences
    idiff=abs(iout-ii);
    jdiff=abs(jout-jj);

    % display differences
    figure;
    imshow(1000*[idiff,jdiff]+0.5);
    title('Test Camera Array Projection Round Trip (image area should be gray)');
    drawnow;
  end
end

% For each valid index in the GPS data domain, evaluate the reference
%   trajectory and compare with the reported GPS position
function testGPSaccuracy(gpsHandle,refTraj)
  if(~refresh(gpsHandle))
    error('gps is not ready');
  end
  
  ka=first(gpsHandle);
  kb=last(gpsHandle);
  assert(isa(ka,'uint32'));
  assert(isa(kb,'uint32'));
  
  K=1+kb-ka;
  gpsLonLatAlt=zeros(3,K);
  trueECEF=zeros(3,K);
  for indx = 1:K
    currTime = getTime(gpsHandle,indx);
    trueECEF(:,indx) = evaluate(refTraj,currTime);
    [gpsLonLatAlt(1,indx),gpsLonLatAlt(2,indx),gpsLonLatAlt(3,indx)] = getGlobalPosition(gpsHandle,ka+indx-1);
  end
  trueLonLatAlt = ecef2lolah(trueECEF);
  errLonLatAlt = gpsLonLatAlt-trueLonLatAlt;

  figure;
  hist(errLonLatAlt(1,:));
  title('GPS error (longitude)');
  
  figure;
  hist(errLonLatAlt(2,:));
  title('GPS error (latitude)');
  
  figure;
  hist(errLonLatAlt(3,:));
  title('GPS error (altitude)');
  
  figure;
  gpsECEF=lolah2ecef(gpsLonLatAlt);
  errECEF=gpsECEF-trueECEF;
  Raxes=[0,0,-1;0,1,0;1,0,0];
  R=Euler2Matrix([0;-trueLonLatAlt(2,1);trueLonLatAlt(1,1)])*Raxes;
  errNED=R*errECEF;
  plot3(errNED(1,:),errNED(2,:),errNED(3,:),'b.');
  title('GPS error (scatter plot)');
  xlabel('north (meters)');
  ylabel('east (meters)');
  zlabel('down (meters)');
  axis('equal');
  drawnow;
end

% Converts rotation from Euler to matrix form
function M=Euler2Matrix(Y)
  Y1=Y(1);
  Y2=Y(2);
  Y3=Y(3);
  c1=cos(Y1);
  c2=cos(Y2);
  c3=cos(Y3);
  s1=sin(Y1);
  s2=sin(Y2);
  s3=sin(Y3);
  M=zeros(3);
  M(1,1)=c3.*c2;
  M(1,2)=c3.*s2.*s1-s3.*c1;
  M(1,3)=s3.*s1+c3.*s2.*c1;
  M(2,1)=s3.*c2;
  M(2,2)=c3.*c1+s3.*s2.*s1;
  M(2,3)=s3.*s2.*c1-c3.*s1;
  M(3,1)=-s2;
  M(3,2)=c2.*s1;
  M(3,3)=c2.*c1;
end

% Converts from LOLAH to ECEF
%
% INPUT
% lolah = [ Longitude (radians) ; Latitude (radians) ; Height (meters) ], 3-by-N
%
% OUTPUT
% ecef = Earth Centered Earth Fixed coordinates
%        UEN orientation at the meridian/equator origin (meters), 3-by-N
% 
% NOTES
% http://www.microem.ru/pages/u_blox/tech/dataconvert/GPS.G1-X-00006.pdf
%   Retrieved 11/30/2009
function ecef=lolah2ecef(lolah)
  lon = lolah(1,:);
  lat = lolah(2,:);
  alt = lolah(3,:);
  a = 6378137;
  finv = 298.257223563;
  b = a-a/finv;
  a2 = a.*a;
  b2 = b.*b;
  e = sqrt((a2-b2)./a2);
  slat = sin(lat);
  clat = cos(lat);
  N = a./sqrt(1-(e*e)*(slat.*slat));
  ecef = [(alt+N).*clat.*cos(lon);
          (alt+N).*clat.*sin(lon);
          ((b2./a2)*N+alt).*slat];
end

% Converts ECEF coordinates to longitude, latitude, height
%
% INPUT
% ecef = points in ECEF coordinates, 3-by-N
%
% OUTPUT
% lolah = converted points, 3-by-N
%   lolah(1,:) = longitude in radians
%   lolah(2,:) = geodetic (not geocentric) latitude in radians
%   lolah(3,:) = height above the WGS84 Earth ellipsoid in meters
%
% NOTES
% J. Zhu, "Conversion of Earth-centered Earth-fixed coordinates to geodetic
%   coordinates," Aerospace and Electronic Systems, vol. 30, pp. 957-961, 1994.
function lolah=ecef2lolah(ecef)
  X = ecef(1,:);
  Y = ecef(2,:);
  Z = ecef(3,:);
  a = 6378137.0;
  finv = 298.257223563;
  f = 1/finv;
  b = a-a/finv;
  e2 = 2*f-f^2;
  ep2 = f*(2-f)/((1-f)^2);
  r2 = X.^2+Y.^2;
  r = sqrt(r2);
  E2 = a^2 - b^2;
  F = 54*b^2*Z.^2;
  G = r2 + (1-e2)*Z.^2 - e2*E2;
  c = (e2*e2*F.*r2)./(G.*G.*G);
  s = ( 1 + c + sqrt(c.*c + 2*c) ).^(1/3);
  P = F./(3*(s+1./s+1).^2.*G.*G);
  Q = sqrt(1+2*e2*e2*P);
  ro = -(e2*P.*r)./(1+Q) + sqrt((a*a/2)*(1+1./Q) - ((1-e2)*P.*Z.^2)./(Q.*(1+Q)) - P.*r2/2);
  tmp = (r - e2*ro).^2;
  U = sqrt( tmp + Z.^2 );
  V = sqrt( tmp + (1-e2)*Z.^2 );
  zo = (b^2*Z)./(a*V);
  lolah = [atan2(Y,X);atan( (Z + ep2*zo)./r );U.*( 1 - b^2./(a*V))];
end
