classdef OptimizerWrapper < Optimizer

  properties (SetAccess=private,GetAccess=private)
    c % class name
    h % handle to instantiated C++ object
  end
  
  methods (Access=public)
    function this=OptimizerWrapper(pkg,uri)
      this=this@Optimizer(uri);
      this.c=[pkg,'.',pkg];
      this.h=feval(this.c,pkg,uri);
    end

    function num=numResults(this)
      num=feval(this.c,this.h,'numResults');
    end
    
    function xEst=getTrajectory(this)
      xEst=feval(this.c,this.h,'getTrajectory');
    end
    
    function cEst=getCost(this)
      cEst=feval(this.c,this.h,'getCost');
    end
    
    function step(this)
      feval(this.c,this.h,'step');
    end
  end
  
end
