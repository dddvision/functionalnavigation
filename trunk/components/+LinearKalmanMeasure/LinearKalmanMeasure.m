% This measure simulates a sensor that measures the body position
%   and adds error sampled from a normal distribution
classdef LinearKalmanMeasure < LinearKalmanMeasure.LinearKalmanMeasureConfig & Measure

  properties (SetAccess=private,GetAccess=private)
    xRef
    t
    yBar
    ka
    kb
    status
  end
  
  methods (Access=public)
    function this=LinearKalmanMeasure(uri)
      this=this@Measure(uri);
           
      try
        [scheme,resource]=strtok(uri,':');
        resource=resource(2:end);
        switch(scheme)
          case 'matlab'
            container=DataContainer.factory(resource);
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

    function refresh(this)
      if(this.status)
        time=this.t(end)+this.dt;
      else
        time=domain(this.xRef);
      end
      truth=evaluate(this.xRef,time);
      if(~isnan(truth))
        this.t=[this.t,time];
        this.yBar=[this.yBar,truth(1)+this.deviation*randn];
        if(this.status)
          this.kb=this.kb+uint32(1);
        else
          this.ka=uint32(1);
          this.kb=uint32(1);
          this.status=true;
        end
      else
        fprintf('\nWarning: Simulation has run out of reference data.');
      end
    end

    function flag=hasData(this)
      flag=this.status;
    end

    function ka=first(this)
      assert(this.status)
      ka=this.ka;
    end
    
    function kb=last(this)
      assert(this.status)
      kb=this.kb;
    end

    function time=getTime(this,k)
      time=this.t(k);
    end
    
    function [ka,kb]=findEdges(this,kaMin,kbMin)
      assert(isa(kaMin,'uint32'));
      assert(isa(kbMin,'uint32'));
      assert(numel(kaMin)==1);
      assert(numel(kbMin)==1);
      if(this.status)
        ka=max([this.ka,kaMin,kbMin]):this.kb;
        kb=ka;
      else
        ka=uint32([]);
        kb=uint32([]);
      end
    end

    function cost=computeEdgeCost(this,x,a,b)
      assert(isa(x,'Trajectory'));
      assert(isa(a,'uint32'));
      assert(isa(b,'uint32'));
      assert(numel(x)==1);
      assert(numel(a)==1);
      assert(numel(b)==1);
      assert(this.status);
      assert(a==b);
      pos=evaluate(x,this.t(b));
      dnorm=(this.yBar(b)-pos(1))./this.deviation;
      cost=0.5*dnorm.*dnorm;
    end
  end
  
end
