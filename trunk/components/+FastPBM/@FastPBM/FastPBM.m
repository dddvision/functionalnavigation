classdef FastPBM < tom.Measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
  end
  
  methods (Static=true,Access=public)
    function initialize(name)
      function text=componentDescription
        text='Implements a fast visual feature tracker and associated trajectory measure.';
      end
      tom.Measure.connect(name,@componentDescription,@FastPBM.FastPBM);
    end
  end
  
  methods (Access=public)
    function this=FastPBM(uri)
      this=this@tom.Measure(uri);
    end
    
    function refresh(this)
      refresh(this.sensor);
    end
    
    function flag=hasData(this)
      flag=hasData(this.sensor);
    end
    
    function n=first(this)
      n=first(this.sensor);
    end
    
    function n=last(this)
      n=last(this.sensor);
    end
    
    function time=getTime(this,n)
      time=getTime(this.sensor,n);
    end
    
    function edgeList=findEdges(this,x,naMin,naMax,nbMin,nbMax)
      assert(isa(x,'tom.Trajectory'));
      edgeList=repmat(tom.GraphEdge,[0,1]);
      if(hasData(this.sensor))
        nMin=max([naMin,first(this.sensor),nbMin-uint32(1)]);
        nMax=min([naMax+uint32(1),last(this.sensor),nbMax]);
        nList=nMin:nMax;
        [na,nb]=ndgrid(nList,nList);
        keep=nb(:)>na(:);
        na=na(keep);
        nb=nb(keep);
        if(~isempty(na))
          edgeList=tom.GraphEdge(na,nb);
        end
      end
    end
    
    function cost=computeEdgeCost(this,x,graphEdge)
      % return 0 if the specified edge is not found in the graph
      isAdjacent = ((graphEdge.first+uint32(1))==graphEdge.second) && ...
        hasData(this.sensor) && ...
        (graphEdge.first>=first(this.sensor)) && ...
        (graphEdge.second<=last(this.sensor));
      if(~isAdjacent)
        cost=0;
        return;
      end

      % return NaN if the graph edge extends outside of the trajectory domain
      ta=getTime(this.sensor,graphEdge.first);
      tb=getTime(this.sensor,graphEdge.second);
      interval=domain(x);
      if((ta<interval.first)||(tb>interval.second))
        cost=NaN;
        return;
      end

      poseA=evaluate(x,ta);
      poseB=evaluate(x,tb);

    end
  end
  
end
