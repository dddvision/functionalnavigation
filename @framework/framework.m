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
        for k=2:config.popsize
          this.x(k)=feval(config.trajectory);
        end
        this.g{1}=feval(config.sensor);
        % TODO: add other sensors
      end
    end
    
    function [this,xout,c]=step(this)
      tmin=1.0;
      tmax=1.5;
      
      xout=this.x;
      c=evaluate(this.g{1},this.x,tmin,tmax);
           
      vStatic=[];
      vDynamic=[];
      for k=1:numel(this.x)
        vStatic=[vStatic;getStaticSeed(this.x(k))];
        vDynamic=[vDynamic;getDynamicSubSeed(this.x(k),tmin,tmax)];
      end
      
      wStatic=[];
      wDynamic=[];
      for k=1:numel(this.g)
        wStatic=[wStatic;getStaticSeed(this.g{k})];
        wDynamic=[wDynamic;getDynamicSubSeed(this.g{k},tmin,tmax)];
      end
      
      % TODO: combine costs from multiple sensors
      
      vSplit=size(vStatic,2);
      wSplit=size(wStatic,2);
      
      v=[vStatic,vDynamic];
      w=[wStatic,wDynamic];
            
      [this.M,v,w]=step(this.M,v,w,c);

      for k=1:numel(this.x)
        this.x(k)=setStaticSeed(this.x(k),v(k,1:vSplit));
        this.x(k)=setDynamicSubSeed(this.x(k),v(k,(vSplit+1):end),tmin,tmax);
      end
      
      for k=1:numel(this.g)
        this.g{k}=setStaticSeed(this.g{k},w(k,1:wSplit));
        this.g{k}=setDynamicSubSeed(this.g{k},w(k,(wSplit+1):end),tmin,tmax);
      end
      
    end
  end
end
