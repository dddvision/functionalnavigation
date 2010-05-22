classdef MeasureWrapper < Measure

  properties (SetAccess=private,GetAccess=private)
    c % class name
    h % handle to instantiated C++ object
  end
  
  methods (Access=public)
    function this=MeasureWrapper(pkg,uri)
      this=this@Measure(uri);
      this.c=[pkg,'.',pkg];
      this.h=feval(this.c,pkg,uri);
    end

    function refresh(this)
      feval(this.c,this.h,'refresh');
    end

    function flag=hasData(this)
      flag=feval(this.c,this.h,'hasData');
    end

    function ka=first(this)
      ka=feval(this.c,this.h,'first');
    end
    
    function kb=last(this)
      kb=feval(this.c,this.h,'last');
    end

    function time=getTime(this,k)
      time=feval(this.c,this.h,'getTime',k);
    end
    
    function edge=findEdges(this,kaSpan,kbSpan)
      % implements workaround that calls repmat(Edge,...) internally
      edge=Edge(uint32(0),uint32(0));
      edge=feval(this.c,this.h,'findEdges',edge,kaSpan,kbSpan);
    end

    function cost=computeEdgeCost(this,x,edge)
      % implements a workaround that depends on a Trajectory named 'x'
      assert(isa(x,'Trajectory'));
      cost=feval(this.c,this.h,'computeEdgeCost',edge);
    end
  end
  
end
