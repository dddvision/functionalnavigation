classdef XMeasure < Default.DefaultConfig & tom.Measure

  properties (SetAccess=private,GetAccess=private)
    xRef
    t
    yBar
    na
    nb
    status
  end

  methods (Static=true,Access=public)
    function initialize(name)
      function text=componentDescription
        text=['Evaluates a reference trajectory and simulates measurement of initial ECEF X positon with error. ',...
          'Error is simulated by sampling from a normal distribution.'];
      end
      tom.Measure.connect(name,@componentDescription,@Default.XMeasure);
    end
  end
  
  methods (Access=public)
    function this=XMeasure(uri)
      this=this@tom.Measure(uri);
      try
        [scheme,resource]=strtok(uri,':');
        resource=resource(2:end);
        switch(scheme)
          case 'matlab'
            container=tom.DataContainer.create(resource);
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
      this.t=tom.WorldTime([]);
      this.yBar=[];
      this.na=uint32([]);
      this.nb=uint32([]);
      this.status=false;
    end

    function refresh(this)
      if(this.status)
        time=tom.WorldTime(this.t(end)+this.dt);
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
      time=tom.WorldTime(this.t(n));
    end
    
    function edgeList=findEdges(this,x,naMin,naMax,nbMin,nbMax)
      assert(isa(x,'tom.Trajectory'));
      edgeList=repmat(tom.GraphEdge,[0,1]);
      if(this.status)
        nMin=max([this.na,naMin,nbMin]);
        nMax=min([this.nb,naMax,nbMax]);
        node=nMin:nMax;
        if(nMax>=nMin)
          edgeList=tom.GraphEdge(node,node);
        end
      end
    end

    function cost=computeEdgeCost(this,x,graphEdge)
      % return 0 if the specified edge is not found in the graph
      isAdjacent = this.status && ...
        (graphEdge.first==graphEdge.second) && ...
        (graphEdge.first>=this.na) && ...
        (graphEdge.second<=this.nb);
      if(~isAdjacent)
        cost=0;
        return;
      end
         
      % return NaN if the graph edge extends outside of the trajectory domain
      time=this.t(graphEdge.second);
      interval=domain(x);
      if((time<interval.first)||(time>interval.second))
        cost=NaN;
        return;
      end
      
      pose=evaluate(x,time);
      dnorm=(this.yBar(graphEdge.second)-pose.p(1))./this.deviation;
      cost=0.5*dnorm.*dnorm;
    end
  end
  
end
