classdef framework
  properties
    optimizer
    trajectory
    measure
    cpuDelta
    popsize
    tmin
  end
  methods
    
    function this=framework(config)
      fprintf('\n');
      fprintf('\nframework::framework');
      
      if(nargin>0)
        addpath(config.trajectoryComponentPath);
        fprintf('\npath added: %s',config.trajectoryComponentPath);
        addpath(config.measureComponentPath);
        fprintf('\npath added: %s',config.measureComponentPath);
        addpath(config.optimizerComponentPath);
        fprintf('\npath added: %s',config.optimizerComponentPath);
        
        % TODO: set adaptively to manage computation
        this.cpuDelta=0.0;
        this.popsize=10;
        this.tmin=1.3;
 
        % initialize optimizer
        this.optimizer=feval(config.optimizer);
        
        % initialize trajectories and measures
        this.trajectory=feval(config.trajectory);
        this.measure{1}=feval(config.measure);
        for k=2:this.popsize
          this.trajectory(k,1)=feval(config.trajectory);
          this.measure{1}(k,1)=feval(config.measure);
        end
        % TODO: enable multiple measures
       end
    end
    
    % Execute one step of the framework to improve the tail portion of
    %   a set of trajectories
    %
    % OUTPUT
    % xEstimate = trajectory objects, popsize-by-1
    % cost = non-negative cost associated with each trajectory object, double popsize-by-1
    % costPotential = uppper bound cost that could have accrued, double scalar
    function [this,xEstimate,cost,costPotential]=step(this)
      [parameters,meta]=getParameters(this);
      objective('put',this,meta);
      cpuStart=tic;
      costPotential=0;
      for k=1:this.popsize
        costPotential=max(costPotential,upperBound(this.measure{1}(k),this.tmin));
      end
      [this.optimizer,cost]=defineProblem(this.optimizer,@objective,parameters);
      cpuStep=toc(cpuStart);
      while(true)
        [this.optimizer,parameters,cost]=step(this.optimizer);
        if((toc(cpuStart)+cpuStep)>this.cpuDelta)
          break;
        end
      end
      this=putParameters(this,parameters,meta);
      xEstimate=this.trajectory;
    end
    
  end
end

% private
function [bits,meta]=getParameters(this)
  vDynamic=[];
  wDynamic=[];
  for k=1:numel(this.trajectory)
    vDynamic=[vDynamic;getBits(this.trajectory(k),this.tmin)];
    wDynamic=[wDynamic;getBits(this.measure{1}(k),this.tmin)];
  end

  % indexing must deal with empty vectors
  meta.vDynamicIndex = 1:size(vDynamic,2);
  meta.wDynamicIndex = numel(meta.vDynamicIndex) + (1:size(wDynamic,2));

  bits=[vDynamic,wDynamic];
end

% private
function this=putParameters(this,parameters,meta)
  for k=1:this.popsize
    this.trajectory(k)=putBits(this.trajectory(k),parameters(k,meta.vDynamicIndex),this.tmin);
    this.measure{1}(k)=putBits(this.measure{1}(k),parameters(k,meta.wDynamicIndex),this.tmin);
  end
end

% private
function varargout=objective(varargin)
  persistent this meta
  parameters=varargin{1};
  if(~ischar(parameters))
    this=putParameters(this,parameters,meta);
    cost=zeros(this.popsize,1);
    for k=1:this.popsize
      cost(k)=evaluate(this.measure{1}(k),this.trajectory(k),this.tmin);
    end
    % TODO: enable multiple measures
    varargout{1}=cost;
  elseif(strcmp(parameters,'put'))
    this=varargin{2};
    meta=varargin{3};
  else
    error('incorrect argument list');
  end
end
