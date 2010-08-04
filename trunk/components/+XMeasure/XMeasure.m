% This measure simulates a sensor that measures the ECEF X coordinate of a reference trajectory
%   and adds error sampled from a normal distribution
classdef XMeasure < XMeasure.XMeasureConfig & Measure

  properties (SetAccess=private,GetAccess=private)
    xRef
    t
    yBar
    na
    nb
    status
  end
  
  methods (Access=public)
    function this=XMeasure(uri)
      this=this@Measure(uri);
      try
        [scheme,resource]=strtok(uri,':');
        resource=resource(2:end);
        switch(scheme)
          case 'matlab'
            if(this.verbose)
              fprintf('\n\nWarning: XMeasure is simulated from a reference trajectory');
            end
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
      this.na=uint32([]);
      this.nb=uint32([]);
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
          this.nb=this.nb+uint32(1);
        else
          this.na=uint32(1);
          this.nb=uint32(1);
          this.status=true;
        end
      else
        if(this.verbose)
          fprintf('\n\nWarning: Simulation has run out of reference data');
        end
      end
    end

    function flag=hasData(this)
      flag=this.status;
    end

    function na=first(this)
      assert(this.status)
      na=this.na;
    end
    
    function nb=last(this)
      assert(this.status)
      nb=this.nb;
    end

    function time=getTime(this,n)
      time=WorldTime(this.t(n));
    end
    
    function edgeList=findEdges(this,x,naSpan,nbSpan)
      assert(isa(x,'Trajectory'));
      assert(isa(naSpan,'uint32'));
      assert(isa(nbSpan,'uint32'));
      assert(numel(naSpan)==1);
      assert(numel(nbSpan)==1);
      if(this.status)
        nMin=max([this.na,this.nb-naSpan,this.nb-nbSpan]);
        nMax=this.nb;
        node=nMin:nMax;
      end
      if(nMax>=nMin)
        edgeList=GraphEdge(node,node);
      else
        edgeList=repmat(GraphEdge,[0,1]);
      end
    end

    function cost=computeEdgeCost(this,x,graphEdge)
      assert(isa(x,'Trajectory'));
      assert(isa(graphEdge,'GraphEdge'));
      assert(numel(x)==1);
      assert(numel(graphEdge)==1);
      assert(this.status);
      assert(graphEdge.first==graphEdge.second);
      pose=evaluate(x,this.t(graphEdge.second));
      dnorm=(this.yBar(graphEdge.second)-pose.p(1))./this.deviation;
      cost=0.5*dnorm.*dnorm;
    end
  end
  
end
