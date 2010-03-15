% This measure simulates a sensor that measures the body position
%   and adds error sampled from a normal distribution
classdef linearKalmanMeasure < linearKalmanMeasure.linearKalmanMeasureConfig & measure

  properties (SetAccess=private,GetAccess=private)
    xRef
    t
    yBar
    ka
    kb
    status
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
            else
              error('Simulator requires reference trajectory');
            end
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end
      this.t=[];
      this.yBar=[];
      this.ka=uint32([]);
      this.kb=uint32([]);
      this.status=false;
    end

    function status=refresh(this)
      if(this.status)
        time=this.t(end)+this.dt;
      else
        time=domain(this.xRef);
      end
      truth=evaluate(this.xRef,time);
      if(~isnan(truth))
        this.t=[this.t,time];
        this.yBar=[this.yBar,truth(1)+this.sigma*randn];
        if(this.status)
          this.kb=this.kb+uint32(1);
        else
          this.ka=uint32(1);
          this.kb=uint32(1);
          this.status=true;
        end
      end
      status=this.status;
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
      dnorm=(this.yBar(b)-pos(1))./this.sigma;
      cost=0.5*dnorm.*dnorm;
    end
  end
  
end
