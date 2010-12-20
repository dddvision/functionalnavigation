classdef XMeasure < XMeasure.XMeasureConfig & tom.Measure

  properties (SetAccess=private,GetAccess=private)
    xRef
    ta
    initTime
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
      tom.Measure.connect(name,@componentDescription,@XMeasure.XMeasure);
    end
  end
  
  methods (Access=public)
    function this=XMeasure(initialTime,uri)
      this=this@tom.Measure(initialTime,uri);
      if(~strncmp(uri,'antbed:',7))
        error('URI scheme not recognized');
      end
      container=antbed.DataContainer.create(uri(8:end),initialTime);
      if(hasReferenceTrajectory(container))
        this.xRef=getReferenceTrajectory(container);
      else
        this.xRef=tom.DynamicModelDefault(initialTime,uri);
      end
      interval=this.xRef.domain();
      this.ta=interval.first;
      this.initTime=initialTime;
      this.yBar=[];
      this.na=uint32(0);
      this.status=false;
    end

    function refresh(this,x)
      assert(isa(x,'tom.Trajectory'));
      if(this.status)
        this.nb=this.nb+uint32(1);
      else
        this.nb=this.na;
        this.status=true;
      end
      time=tom.WorldTime(this.ta+double(this.nb)*this.dt);
      pose=evaluate(this.xRef,time);
      this.yBar=[this.yBar,pose.p(1)+this.deviation*randn];
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
      time=tom.WorldTime(this.initTime+double(n)*this.dt);
    end
    
    function edgeList=findEdges(this,naMin,naMax,nbMin,nbMax)
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
      time=this.getTime(graphEdge.second);
      interval=domain(x);
      if(time<interval.first)
        cost=NaN;
        return;
      end
      
      pose=evaluate(x,time);
      dnorm=(this.yBar(graphEdge.second+1)-pose.p(1))./this.deviation;
      cost=0.5*dnorm.*dnorm;
    end
  end
  
end
