classdef linearKalmanMeasure < measure

  properties (SetAccess=private,GetAccess=private)
    sensor
    ka
    kb
    t
    yBar
    sigma
    dt
  end
  
  methods (Access=protected)
    function this=linearKalmanMeasure(uri)
      this=this@measure(uri);
      
      this.ka=uint32(1);
      this.kb=uint32(1);
      this.dt=0.1; % ASSUMPTION: fixed known time step
      this.sigma=2; % ASSUMPTION: fixed known noise parameter
      
      % ASSUMPTION: simple linear noise process
      % noise[k+1]=noise[k]+sigma*randn[k]
      try
        [scheme,resource]=strtok(uri,':');
        switch(scheme)
          case 'matlab'
            container=eval(resource(2:end));
            if(hasReferenceTrajectory(container))
              xRef=getReferenceTrajectory(container);
              [ta,tb]=domain(xRef);
              this.t=ta:this.dt:tb;
              x=evaluate(xRef,this.t);
              noise=cumsum(this.sigma*randn(1,numel(this.t)));
              this.yBar=x(1,:)+noise;
            else
              error('Simulator requires reference trajectory');
            end
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end
    end

   function status=refresh(this)
      if(this.kb<numel(this.t))
        this.kb=this.kb+uint32(1);
      end
      status=true;
    end
    
    function time=getTime(this,k)
      time=this.t(k);
    end
    
    function a=first(this)
      a=this.ka;
    end
    
    function b=last(this)
      b=this.kb;
    end
    
    function [ka,kb]=findEdges(this,kaMin,kbMin)
      k=last(this.sensor);
      if((k<kaMin)||(k<kbMin))
        ka=[];
        kb=[];
      else
        ka=k;
        kb=k;
      end      
    end

    function cost=computeEdgeCost(this,x,a,b)
      assert(a==b);
      pos=evaluate(x,this.time(1:b));
      yHat=pos(1,:);
      yDif=this.yBar(1:b)-yHat;
      
      
      
      cost=0.5*(y-yHat)*(1/this.sigma)*(y-yHat);
    end
  end
  
end
