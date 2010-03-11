% This measure simulates a sensor that measures the body position
%   and adds error sampled from a normal distribution
classdef linearKalmanMeasure < linearKalmanMeasure.linearKalmanMeasureConfig & measure

  properties (SetAccess=private,GetAccess=private)
    xRef
    t
    yBar
    ka
    kb
  end
  
  methods (Access=public)
    function this=linearKalmanMeasure(uri)
      this=this@measure(uri);
           
      try
        [scheme,resource]=strtok(uri,':');
        switch(scheme)
          case 'matlab'
            container=eval(resource(2:end));
            if(hasReferenceTrajectory(container))
              this.xRef=getReferenceTrajectory(container);
              this.t=domain(this.xRef);
              this.yBar=evaluate(this.xRef,this.t)+this.sigma*randn;
            else
              error('Simulator requires reference trajectory');
            end
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end
      this.ka=uint32(1);
      this.kb=uint32(1);
    end

    function status=refresh(this)
      time=this.t(end)+this.dt;
      truth=evaluate(this.xRef,time);
      if(~isnan(truth))
        this.t=[this.t,time];
        this.yBar=[this.yBar,truth+this.sigma*randn];
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
      ka=max([this.ka,kaMin,kbMin]):this.kb;
      kb=ka;
    end

    function cost=computeEdgeCost(this,x,a,b)
      assert(a==b);
      pos=evaluate(x,this.t(b));
      dnorm=(this.yBar(1,b)-pos(1))./this.sigma;
      cost=0.5*dnorm.*dnorm;
    end
  end
  
end
