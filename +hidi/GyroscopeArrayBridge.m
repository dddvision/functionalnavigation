classdef GyroscopeArrayBridge < hidi.GyroscopeArray
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
  end
  
  methods (Access = public)
    function this = GyroscopeArrayBridge(m)
      this.m = m;
    end
    
    function refresh(this)
      feval(this.m, 'gyroscopeArrayRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, 'gyroscopeArrayHasData');
    end
    
    function n = first(this)
      n = feval(this.m, 'gyroscopeArrayFirst');
    end
    
    function n = last(this)
      n = feval(this.m, 'gyroscopeArrayLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, 'gyroscopeArrayGetTime', n);
    end
    
    function rate = getAngularRate(this, n, ax)
      rate = feval(this.m, 'getAngularRate', n, ax);
    end
    
    function rate = getAngularRateCalibrated(this, n, ax)
      rate = feval(this.m, 'getAngularRateCalibrated', n, ax);
    end
    
    function walk = getGyroscopeAngleRandomWalk(this)
      walk = feval(this.m, 'getGyroscopeAngleRandomWalk');
    end
    
    function sigma = getGyroscopeTurnOnBiasSigma(this)
      sigma = feval(this.m, 'getGyroscopeTurnOnBiasSigma');
    end
    
    function sigma = getGyroscopeInRunBiasSigma(this)
      sigma = feval(this.m, 'getGyroscopeInRunBiasSigma');
    end
    
    function tau = getGyroscopeInRunBiasStability(this)
      tau = feval(this.m, 'getGyroscopeInRunBiasStability');
    end
    
    function sigma = getGyroscopeTurnOnScaleSigma(this)
      sigma = feval(this.m, 'getGyroscopeTurnOnScaleSigma');
    end
    
    function sigma = getGyroscopeInRunScaleSigma(this)
      sigma = feval(this.m, 'getGyroscopeInRunScaleSigma');
    end
    
    function tau = getGyroscopeInRunScaleStability(this)
      tau = feval(this.m, 'getGyroscopeInRunScaleStability');
    end
  end
end
