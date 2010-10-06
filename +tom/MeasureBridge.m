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
      error('tom.MeasureBridge has not been fully implemented')
    end

    function refresh(this,x)
      assert(isa(x,'tom.Trajectory'));
      feval(this.m,this.h,'refresh',x);
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
    
    function graphEdge=findEdges(this,naMin,naMax,nbMin,nbMax)
      graphEdge=feval(this.m,this.h,'findEdges',naMin,naMax,nbMin,nbMax);
    end

    function cost=computeEdgeCost(this,x,graphEdge)
      % implements a workaround that depends on a Trajectory named 'x'
      assert(isa(x,'tom.Trajectory'));
      cost=feval(this.m,this.h,'computeEdgeCost',graphEdge);
    end
  end
  
end
