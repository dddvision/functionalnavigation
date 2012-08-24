classdef GyroscopeArrayBridge < hidi.GyroscopeArray
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    h % handle to C++ object
  end
  
  methods (Access = public)
    function this = GyroscopeArrayBridge(m, h)
      if(nargin>0)
        this.m = m;
        this.h = h;
      end
    end
    
    function refresh(this)
      feval(this.m, this.h, 'gyroscopeArrayRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, this.h, 'gyroscopeArrayHasData');
    end
    
    function n = first(this)
      n = feval(this.m, this.h, 'gyroscopeArrayFirst');
    end
    
    function n = last(this)
      n = feval(this.m, this.h, 'gyroscopeArrayLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, this.h, 'gyroscopeArrayGetTime', n);
    end
    
    function rate = getAngularRate(this, n, ax)
      rate = feval(this.m, this.h, 'getAngularRate', n, ax);
    end
    
    function walk = getGyroscopeRandomWalk(this)
      walk = feval(this.m, this.h, 'getGyroscopeRandomWalk');
    end
    
    function sigma = getGyroscopeTurnOnBiasSigma(this)
      sigma = feval(this.m, this.h, 'getGyroscopeTurnOnBiasSigma');
    end
    
    function sigma = getGyroscopeInRunBiasSigma(this)
      sigma = feval(this.m, this.h, 'getGyroscopeInRunBiasSigma');
    end
    
    function tau = getGyroscopeInRunBiasStability(this)
      tau = feval(this.m, this.h, 'getGyroscopeInRunBiasStability');
    end
    
    function sigma = getGyroscopeTurnOnScaleSigma(this)
      sigma = feval(this.m, this.h, 'getGyroscopeTurnOnScaleSigma');
    end
    
    function sigma = getGyroscopeInRunScaleSigma(this)
      sigma = feval(this.m, this.h, 'getGyroscopeInRunScaleSigma');
    end
    
    function tau = getGyroscopeInRunScaleStability(this)
      tau = feval(this.m, this.h, 'getGyroscopeInRunScaleStability');
    end
  end
end
