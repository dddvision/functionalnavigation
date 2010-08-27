classdef MeasureBridge < Measure

  properties (SetAccess=private,GetAccess=private)
    c % class name
    h % handle to instantiated C++ object
  end
  
  methods (Access=public)
    function this=MeasureBridge(name,uri)
      this=this@Measure(uri);
      this.c=[name,'.',name];
      this.h=feval(this.c,name,uri);
    end

    function refresh(this)
      feval(this.c,this.h,'refresh');
    end

    function flag=hasData(this)
      flag=feval(this.c,this.h,'hasData');
    end

    function na=first(this)
      na=feval(this.c,this.h,'first');
    end
    
    function nb=last(this)
      nb=feval(this.c,this.h,'last');
    end

    function time=getTime(this,n)
      time=feval(this.c,this.h,'getTime',n);
    end
    
    function graphEdge=findEdges(this,x,naSpan,nbSpan)
      error('MeasureBridge::findEdges has not been implemented')
      assert(isa(x,'Trajectory'));
      graphEdge=feval(this.c,this.h,'findEdges',x,naSpan,nbSpan);
    end

    function cost=computeEdgeCost(this,x,graphEdge)
      % implements a workaround that depends on a Trajectory named 'x'
      assert(isa(x,'Trajectory'));
      cost=feval(this.c,this.h,'computeEdgeCost',graphEdge);
    end
  end
  
end
