classdef OptimizerBridge < tom.Optimizer
% Copyright 2011 Scientific Systems Company Inc., New BSD License

  properties (SetAccess = private, GetAccess = private)
    m % class name
    h % handle to instantiated C++ object
  end
  
  methods (Access = public, Static = true)
    function this = OptimizerBridge(name, dynamicModelName, measureNames, uri)
      this = this@tom.Optimizer(dynamicModelName, measureNames, uri);
      error('\n\ntom.OptimizerBridge has not been fully implemented');
%      this.m = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];
%      this.h = feval(this.m, name, dynamicModelName, measureNames, uri);
    end
  end

  methods (Access = public)
    function num = numResults(this)
      num = feval(this.m, this.h, 'numResults');
    end
    
    function xEst = getTrajectory(this)
      xEst = feval(this.m, this.h, 'getTrajectory');
    end
    
    function cEst = getCost(this)
      cEst = feval(this.m, this.h, 'getCost');
    end
    
    function step(this)
      feval(this.m, this.h, 'step');
    end
  end
  
end
