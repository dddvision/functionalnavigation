classdef MeasureBridge < tom.Measure

  properties (SetAccess=private,GetAccess=private)
    m % class name
    h % handle to instantiated C++ object
  end
  
  methods (Access=public)
    function this=MeasureBridge(name,uri)
      this=this@tom.Measure(uri);
      this.m=[name,'.',name];
      this.h=feval(this.m,name,uri);
    end

    function refresh(this)
      feval(this.m,this.h,'refresh');
    end

    function flag=hasData(this)
      flag=feval(this.m,this.h,'hasData');
    end

    function na=first(this)
      na=feval(this.m,this.h,'first');
    end
    
    function nb=last(this)
      nb=feval(this.m,this.h,'last');
    end

    function time=getTime(this,n)
      time=feval(this.m,this.h,'getTime',n);
    end
    
    function graphEdge=findEdges(this,x,naSpan,nbSpan)
      error('tom.MeasureBridge::findEdges has not been implemented')
      assert(isa(x,'tom.Trajectory'));
      graphEdge=feval(this.m,this.h,'findEdges',x,naSpan,nbSpan);
    end

    function cost=computeEdgeCost(this,x,graphEdge)
      % implements a workaround that depends on a Trajectory named 'x'
      assert(isa(x,'tom.Trajectory'));
      cost=feval(this.m,this.h,'computeEdgeCost',graphEdge);
    end
  end
  
end
