classdef OptimizerBridge < Optimizer

  properties (SetAccess=private,GetAccess=private)
    c % class name
    h % handle to instantiated C++ object
  end
  
  methods (Static=true,Access=public)
    function text=description(name)
      error('\n\nOptimizerBridge has not been implemented');
    end
  end
  
  methods (Access=public)
    function this=OptimizerBridge(name,dynamicModelName,measureNames,uri)
      this=this@Optimizer(dynamicModelName,measureNames,uri);
      error('\n\nOptimizerBridge has not been implemented');
%      this.c=[name,'.',name];
%      this.h=feval(this.c,name,dynamicModelName,measureNames,uri);
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
