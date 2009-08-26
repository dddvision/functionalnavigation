classdef framework
  properties
    M
    x
    g
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
        addpath(config.sensorComponentPath);
        fprintf('\npath added: %s',config.sensorComponentPath);
        addpath(config.optimizerComponentPath);
        fprintf('\npath added: %s',config.optimizerComponentPath);
        
        % TODO: set adaptively to manage computation
        this.cpuDelta=0.0;
        this.popsize=5;
        this.tmin=1.3;
 
        % initialize optimizer
        this.M=feval(config.optimizer);
        
        % initialize trajectories and sensors
        this.x=feval(config.trajectory);
        this.g{1}=feval(config.sensor);
        for k=2:this.popsize
          this.x(k,1)=feval(config.trajectory);
          this.g{1}(k,1)=feval(config.sensor);
        end
        % TODO: enable multiple sensors
       end
    end
    
    function [this,xEstimate,costEstimate]=step(this)
      [parameters,meta]=getParameters(this);
      objective('put',this,meta);
      cpuStart=tic;
      [this.M,costEstimate]=defineProblem(this.M,@objective,parameters);
      cpuStep=toc(cpuStart);
      while(true)
        [this.M,parameters,costEstimate]=step(this.M);
        if((toc(cpuStart)+cpuStep)>this.cpuDelta)
          break;
        end
      end
      this=putParameters(this,parameters,meta);
      xEstimate=this.x;
    end
    
  end
end

function [bits,meta]=getParameters(this)
  vStatic=[];
  vDynamic=[];
  wStatic=[];
  wDynamic=[];
  for k=1:numel(this.x)
    vStatic=[vStatic;staticGet(this.x(k))];
    vDynamic=[vDynamic;dynamicGet(this.x(k),this.tmin)];
    wStatic=[wStatic;staticGet(this.g{1}(k))];
    wDynamic=[wDynamic;dynamicGet(this.g{1}(k),this.tmin)];
  end

  % indexing must deal with empty vectors
  meta.vStaticIndex = 1:size(vStatic,2);
  base = numel(meta.vStaticIndex);
  meta.wStaticIndex = base + (1:size(wStatic,2));
  base = base + numel(meta.wStaticIndex);
  meta.vDynamicIndex = base + (1:size(vDynamic,2));
  base = base + numel(meta.vDynamicIndex);
  meta.wDynamicIndex = base + (1:size(wDynamic,2));

  bits=[vStatic,wStatic,vDynamic,wDynamic];
end

function this=putParameters(this,parameters,meta)
  for k=1:this.popsize
    this.x(k)=staticPut(this.x(k),parameters(k,meta.vStaticIndex));
    this.x(k)=dynamicPut(this.x(k),parameters(k,meta.vDynamicIndex),this.tmin);
    this.g{1}(k)=staticPut(this.g{1}(k),parameters(k,meta.wStaticIndex));
    this.g{1}(k)=dynamicPut(this.g{1}(k),parameters(k,meta.wDynamicIndex),this.tmin);
  end
end

function varargout=objective(varargin)
  persistent this meta
  parameters=varargin{1};
  if(~ischar(parameters))
    this=putParameters(this,parameters,meta);
    c=zeros(this.popsize,1);
    for k=1:this.popsize
      c(k)=evaluate(this.g{1}(k),this.x(k),this.tmin);
    end
    % TODO: enable multiple sensors
    varargout{1}=c;
  elseif(strcmp(parameters,'put'))
    this=varargin{2};
    meta=varargin{3};
  else
    error('incorrect argument list');
  end
end
