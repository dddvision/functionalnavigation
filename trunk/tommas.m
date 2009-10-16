classdef tommas
  
  properties (GetAccess=private,SetAccess=private)
    sensorHandles
    optimizer
    dynamicModel
    measure
    numIterations
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
      this.tmin=0;
      this.popSize=config.popSizeDefault;
      this.numIterations=config.numIterationsDefault;
      
      % initialize optimizer
      this.optimizer=unwrapComponent(config.optimizer);

      % TODO: match multiple measures to multiple sensors
      data=unwrapComponent(config.dataContainer);
      list=listSensors(data,'camera');
      this.sensorHandles{1}=getSensor(data,list(1));
      this.measure{1}=unwrapComponent(config.measure,this.sensorHandles{1});
     
      % initialize trajectories
      for k=1:this.popSize
        this.dynamicModel{k}=unwrapComponent(config.dynamicModel);
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
      for n=1:this.numIterations
        [this.optimizer,parameters,cost]=step(this.optimizer);
      end
      for s=1:numel(this.sensorHandles)
        unlock(this.sensorHandles{s});
      end
      this=putParameters(this,parameters);
      xEstimate=cat(1,this.dynamicModel{:});
    end
  end
  
  methods (Access=private)
    function parameters=getParameters(this)
      parameters=[];
      for k=1:numel(this.dynamicModel)
        parameters=[parameters;getBits(this.dynamicModel{k},this.tmin)];
      end
    end
    
    function this=putParameters(this,parameters)
      for k=1:this.popSize
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
    this=putParameters(this,parameters);
    cost=zeros(this.popSize,1);
    for k=1:this.popSize
      cost(k)=evaluate(this.measure{1},this.dynamicModel{k},this.tmin);
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

