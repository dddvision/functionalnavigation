classdef tommas
  
  properties (GetAccess=private,SetAccess=private)
    sensorHandles
    optimizer
    trajectory
    measure
    iterations
    popSize
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

      addpath(config.componentPath);
      fprintf('\npath added: %s',config.componentPath);

      % TODO: set adaptively to manage computation
      this.iterations=3;
      this.tmin=0;
      this.popSize=config.popSizeDefault;
      
      % initialize optimizer
      this.optimizer=unwrapComponent(config.optimizer);

      % TODO: match multiple measures to multiple sensors
      allSensors=unwrapComponent(config.multiSensor);
      list=listSensors(allSensors,'cameraArray');
      this.sensorHandles{1}=getSensor(allSensors,list(1));
      this.measure{1}=unwrapComponent(config.measure,this.sensorHandles{1});
     
      % initialize trajectories
      for k=1:this.popSize
        this.trajectory{k}=unwrapComponent(config.trajectory);
      end
    end
    
    % Execute one step to improve the tail portion of a set of trajectories
    %
    % OUTPUT
    % xEstimate = trajectory objects, popSize-by-1
    % cost = non-negative cost associated with each trajectory object, double popSize-by-1
    % costPotential = uppper bound cost that could have accrued, double scalar
    function [this,xEstimate,cost]=step(this)
      parameters=getParameters(this);
      objective('put',this);
      for s=1:numel(this.sensorHandles)
        lock(this.sensorHandles{s});
      end
      [this.optimizer,cost]=defineProblem(this.optimizer,@objective,parameters);
      for n=1:this.iterations
        [this.optimizer,parameters,cost]=step(this.optimizer);
      end
      for s=1:numel(this.sensorHandles)
        unlock(this.sensorHandles{s});
      end
      this=putParameters(this,parameters);
      xEstimate=cat(1,this.trajectory{:});
    end
  end
  
  methods (Access=private)
    function parameters=getParameters(this)
      parameters=[];
      for k=1:numel(this.trajectory)
        parameters=[parameters;getBits(this.trajectory{k},this.tmin)];
      end
    end
    
    function this=putParameters(this,parameters)
      for k=1:this.popSize
        this.trajectory{k}=putBits(this.trajectory{k},parameters(k,:),this.tmin);
      end
    end
  end
  
end

% A configurable objective function
function varargout=objective(varargin)
  persistent this
  parameters=varargin{1};
  if(~ischar(parameters))
    this=putParameters(this,parameters);
    cost=zeros(this.popSize,1);
    for k=1:this.popSize
      cost(k)=evaluate(this.measure{1},this.trajectory{k},this.tmin);
    end
    % TODO: enable multiple measures
    varargout{1}=cost;
  elseif(strcmp(parameters,'put'))
    this=varargin{2};
  else
    error('incorrect argument list');
  end
end
