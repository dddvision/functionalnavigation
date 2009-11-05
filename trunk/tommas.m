classdef tommas
  
  properties (GetAccess=private,SetAccess=private)
    sensorHandle
    dynamicModel
    cost
    measures
    optimizer
    tmin
  end
  
  methods (Access=public)
    
    % Construct a Trajectory Optimization Manager for Multiple Algorithms and Sensors
    function this=tommas(config)
      fprintf('\n');
      fprintf('\ntommas::tommas');
      if(nargin~=1)
        error('requires configuration argument');
      end
      warning('on','all');
      intwarning('off');
      reset(RandStream.getDefaultStream);

      % TODO: set adaptively to manage computation
      this.tmin=0;

      % initialize trajectories
      for k=1:config.popSizeDefault
        this.dynamicModel{k}=unwrapComponent(config.dynamicModel);
      end

      % TODO: match multiple measures to multiple sensors
      data=unwrapComponent(config.dataContainer);
      list=listSensors(data,'camera');
      this.sensorHandle{1}=getSensor(data,list(1));
      this.measures{1}=unwrapComponent(config.measure,this.sensorHandle{1});
      
      % initialize optimizer
      this.optimizer=unwrapComponent(config.optimizer);
     
      % determine initial costs
      parameters=getParameters(this);
      objective('put',this);
      lockSensors(this);
      [this.optimizer,this.cost]=defineProblem(this.optimizer,@objective,parameters);
      unlockSensors(this);
    end
    
    % Get the most recent trajectory and cost estimates
    %
    % OUTPUT
    % xEst = trajectory objects, popSize-by-1
    % cEst = non-negative cost associated with each trajectory object, double popSize-by-1
    function [xEst,cEst]=getResults(this)
      xEst=cat(1,this.dynamicModel{:});
      cEst=this.cost;
    end
    
    % Execute one step to improve the tail portion of a set of trajectories
    function this=step(this)
      objective('put',this);
      lockSensors(this);
      [this.optimizer,parameters,this.cost]=step(this.optimizer);
      unlockSensors(this);
      this=putParameters(this,parameters);
    end
  end
  
  methods (Access=public,Static=true)
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
          warning('unrecognized component type');
      end      
    end
  end
  
  methods (Access=private)
    function lockSensors(this)
      for s=1:numel(this.sensorHandle)
        lock(this.sensorHandle{s});
      end
    end
    
    function unlockSensors(this)
      for s=1:numel(this.sensorHandle)
        unlock(this.sensorHandle{s});
      end
    end
    
    function parameters=getParameters(this)
      parameters=[];
      for k=1:numel(this.dynamicModel)
        parameters=[parameters;getBits(this.dynamicModel{k},this.tmin)];
      end
    end
    
    function this=putParameters(this,parameters)
      for k=1:numel(this.dynamicModel)
        this.dynamicModel{k}=putBits(this.dynamicModel{k},parameters(k,:),this.tmin);
      end
    end
  end
  
end

% Configurable objective function
function varargout=objective(varargin)
  persistent this
  parameters=varargin{1};
  if(~ischar(parameters))
    K=numel(this.dynamicModel);
    this=putParameters(this,parameters);
    cost=zeros(K,1);
    for k=1:K
      cost(k)=evaluate(this.measures{1},this.dynamicModel{k},this.tmin);
    end
    % TODO: enable multiple measures
    varargout{1}=cost;
  elseif(strcmp(parameters,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end

% Turn a package identifier into an object
%
% INPUT
% pkg = package identifier (directory name without '+' prefix), string
% varargin = arguments for the class constructor
%
% OUTPUT
% obj = instantiated object, class determined by pkg
%
% NOTES
% The package directory must be on the path
function obj=unwrapComponent(pkg,varargin)
  obj=feval([pkg,'.',pkg],varargin{:});
end

function testDataContainer(container)
  list=listSensors(container,'cameraArray');
  for k=1:numel(list)
    sensor=getSensor(container,list(k));
    lock(sensor);
    testCameraArrayProjection(sensor);
    testCameraArrayProjectionRoundTrip(sensor);
    unlock(sensor);
  end
end

function testCameraArrayProjection(cam)
  % find out which images are available
  [ka,kb]=domain(cam);

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
      newPixels=interp2(gray,pix(1,:)+1,pix(2,:)+1,'*linear',NaN);
      newImage=reshape(newPixels,[HEIGHT,WIDTH]);

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
  [ka,kb]=domain(cam);

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
