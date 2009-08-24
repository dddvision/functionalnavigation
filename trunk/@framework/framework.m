classdef framework
  properties
    M
    x
    g
  end
  methods
    
    function this=framework(config)
      fprintf('\n### framework constructor ###');
      
      if(nargin>0)
        addpath(config.trajectoryComponentPath);
        fprintf('\npath added: %s',config.trajectoryComponentPath);
        addpath(config.sensorComponentPath);
        fprintf('\npath added: %s',config.sensorComponentPath);
        addpath(config.optimizerComponentPath);
        fprintf('\npath added: %s',config.optimizerComponentPath);
        
        this.M=feval(config.optimizer);
        this.x=feval(config.trajectory);
        this.g{1}=feval(config.sensor);
        for k=2:config.popsize
          this.x(k,1)=feval(config.trajectory);
          this.g{1}(k,1)=feval(config.sensor);
        end
        % TODO: enable multiple sensors
       end
    end
    
    function [this,x,c]=step(this)
      
      % computation time to devote
      cpuDelta=10.0;
      
      % time domain to optimize over
      tmin=1.0;
      tmax=1.5;

      vStatic=[];
      vDynamic=[];
      for k=1:numel(this.x)
        vStatic=[vStatic;staticGet(this.x(k))];
        vDynamic=[vDynamic;dynamicGet(this.x(k),tmin,tmax)];
      end
      
      wStatic=[];
      wDynamic=[];
      for k=1:numel(this.g{1})
        wStatic=[wStatic;staticGet(this.g{1}(k))];
        wDynamic=[wDynamic;dynamicGet(this.g{1}(k),tmin,tmax)];
      end
      
      vStaticIndex = 1:size(vStatic,2);
      wStaticIndex = vStaticIndex(end) + (1:size(wStatic,2));
      vDynamicIndex = wStaticIndex(end) + (1:size(vDynamic,2));
      wDynamicIndex = vDynamicIndex(end) + (1:size(wDynamic,2));
      
      vw=[vStatic,wStatic,vDynamic,wDynamic];

      % start the timer and optimize until time runs out
      cpuStart=tic;
      while(true)
        cpuStep=tic;
        [this.M,vw,c]=step(this.M,@nestedObjective,vw);
        if((toc(cpuStart)+toc(cpuStep))>cpuDelta)
          break;
        end
      end
      x=this.x;
        
      function cost=nestedObjective(bits)
        for kk=1:size(bits,1)
          this.x(kk)=staticSet(this.x(kk),bits(kk,vStaticIndex));
          this.x(kk)=dynamicSet(this.x(kk),bits(kk,vDynamicIndex),tmin,tmax);
          this.g{1}(kk)=staticSet(this.g{1}(kk),bits(kk,wStaticIndex));
          this.g{1}(kk)=dynamicSet(this.g{1}(kk),bits(kk,wDynamicIndex),tmin,tmax);
        end
        cost=evaluate(this.g{1},this.x,tmin,tmax);
        % TODO: enable multiple sensors
      end
    end
    
  end
end
