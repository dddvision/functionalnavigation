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
      this.t=WorldTime([]);
      this.yBar=[];
      this.ka=uint32([]);
      this.kb=uint32([]);
      this.status=false;
    end

    function refresh(this)
      if(this.status)
        time=WorldTime(this.t(end)+this.dt);
      else
        interval=domain(this.xRef);
        time=interval.first;
      end
      pose=evaluate(this.xRef,time);
      if(~isnan(pose.p))
        this.t=[this.t,time];
        this.yBar=[this.yBar,pose.p(1)+this.deviation*randn];
        if(this.status)
          this.kb=this.kb+uint32(1);
        else
          this.ka=uint32(1);
          this.kb=uint32(1);
          this.status=true;
        end
      else
        fprintf('\n\nwarning: Simulation has run out of reference data.');
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
      time=WorldTime(this.t(k));
    end
    
    function edgeList=findEdges(this,kaSpan,kbSpan)
      assert(isa(kaSpan,'uint32'));
      assert(isa(kbSpan,'uint32'));
      assert(numel(kaSpan)==1);
      assert(numel(kbSpan)==1);
      if(this.status)
        node=max([this.ka,this.kb-kaSpan,this.kb-kbSpan]):this.kb;
        N=numel(node);
        edgeList=repmat(Edge,[N,1]);
        for n=1:N
          edgeList(n).first=node(n);
          edgeList(n).second=node(n);
        end
      else
        edgeList=repmat(Edge,[0,1]);
      end
    end

    function cost=computeEdgeCost(this,x,edge)
      assert(isa(x,'Trajectory'));
      assert(isa(edge,'Edge'));
      assert(numel(x)==1);
      assert(numel(edge)==1);
      assert(this.status);
      assert(edge.first==edge.second);
      pose=evaluate(x,this.t(edge.second));
      dnorm=(this.yBar(edge.second)-pose.p(1))./this.deviation;
      cost=0.5*dnorm.*dnorm;
    end
  end
  
end
