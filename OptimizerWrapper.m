classdef OptimizerWrapper < Optimizer

  properties (SetAccess=private,GetAccess=private)
    c % class name
    h % handle to instantiated C++ object
  end
  
  methods (Access=public)
    function this=OptimizerWrapper(pkg,uri)
      this=this@Optimizer(uri);
      this.c=pkg;
      this.h=feval(this.c,pkg,uri);
    end

    function [xEst,cEst]=getResults(this)
      [xEst,cEst]=feval(this.c,this.h,'getResults');
    end
    
    function step(this)
      feval(this.c,this.h,'step');
    end
  end
  
end
