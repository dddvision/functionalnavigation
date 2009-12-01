% Trajectory Optimization Manager for Multiple Algorithms and Sensors
classdef tommas < tommasConfig
  
  properties (GetAccess=private,SetAccess=private)
    u
    M
    F
    g
    cost
    tmin
  end
  
  methods (Access=public)
    
    % Constructor
    function this=tommas
      fprintf('\n');
      fprintf('\ntommas::tommas');
      warning('on','all');
      intwarning('off');
      reset(RandStream.getDefaultStream);

      % TODO: move choice of tmin into the optimizer
      this.tmin=0;
      
      % initialize trajectories
      for k=1:this.popSizeDefault
        this.F{k}=unwrapComponent(this.dynamicModel);
      end

      % TODO: match multiple measures to multiple sensors
      data=unwrapComponent(this.dataContainer);
      list=listSensors(data,'camera');
      this.u{1}=getSensor(data,list(1));
      for k=1:numel(this.measures)
        this.g{k}=unwrapComponent(this.measures{k},this.u{k},this.F{1});
      end
        
      % initialize optimizer
      this.M=unwrapComponent(this.optimizer);
     
      % determine initial costs
      parameters=getParameters(this);
      objective('put',this);
      lockSensors(this);
      [this.M,this.cost]=defineProblem(this.M,@objective,parameters);
      unlockSensors(this);
    end
    
    % Execute one step to improve the tail portion of a set of trajectories
    function this=step(this)
      objective('put',this);
      lockSensors(this);
      [this.M,parameters,this.cost]=step(this.M);
      unlockSensors(this);
      this=putParameters(this,parameters);
    end
    
    % Get the most recent trajectory and cost estimates
    %
    % OUTPUT
    % xEst = trajectory instances, popSize-by-1
    % cEst = non-negative cost associated with each trajectory instance, double popSize-by-1
    function [xEst,cEst]=getResults(this)
      xEst=cat(1,this.F{:});
      cEst=this.cost;
    end    
  end
  
  methods (Access=public,Static=true)
    % Test a TOMMAS component
    %
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
  end
  
  methods (Access=private)
    function lockSensors(this)
      for s=1:numel(this.u)
        lock(this.u{s});
      end
    end
    
    function unlockSensors(this)
      for s=1:numel(this.u)
        unlock(this.u{s});
      end
    end
    
    function parameters=getParameters(this)
      K=numel(this.F);
      parameters=repmat(getBits(this.F{1},this.tmin),[K,1]);
      for k=2:K
        parameters(k,:)=getBits(this.F{k},this.tmin);
      end
    end
    
    function this=putParameters(this,parameters)
      for k=1:numel(this.F)
        this.F{k}=putBits(this.F{k},parameters(k,:),this.tmin);
      end
    end
  end
  
end

% Configurable objective function
function varargout=objective(varargin)
  persistent this
  parameters=varargin{1};
  if(~ischar(parameters))
    K=numel(this.F);
    this=putParameters(this,parameters);
    cost=zeros(K,1);
    [a,b]=findEdges(this.g{1});
    for k=1:K
      if( isempty(a) )
        cost(k)=0;
      else
        % TODO: update all measures
        this.g{1}=setTrajectory(this.g{1},this.F{k});
        % TODO: compute cost for multiple edges
        cost(k)=computeEdgeCost(this.g{1},a(1),b(1));
      end
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
% obj = object instance, class determined by pkg
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
  assert(isa(ka,'uint32'));

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
  assert(isa(ka,'uint32'));

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
