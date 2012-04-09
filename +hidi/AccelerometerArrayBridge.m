classdef AccelerometerArrayBridge < hidi.AccelerometerArray
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
  end
  
  methods (Access = public)
    function this = AccelerometerArrayBridge(m)
      this.m = m;
    end
    
    function refresh(this)
      feval(this.m, 'accelerometerArrayRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, 'accelerometerArrayHasData');
    end
    
    function n = first(this)
      n = feval(this.m, 'accelerometerArrayFirst');
    end
    
    function n = last(this)
      n = feval(this.m, 'accelerometerArrayLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, 'accelerometerArrayGetTime', n);
    end
    
    function force = getSpecificForce(this, n, ax)
      force = feval(this.m, 'getSpecificForce', n, ax);
    end
    
    function force = getSpecificForceCalibrated(this, n, ax)
      force = feval(this.m, 'getSpecificForceCalibrated', n, ax);
    end
    
    function walk = getAccelerometerVelocityRandomWalk(this)
      walk = feval(this.m, 'getAccelerometerVelocityRandomWalk');
    end
    
    function sigma = getAccelerometerTurnOnBiasSigma(this)
      sigma = feval(this.m, 'getAccelerometerTurnOnBiasSigma');
    end
    
    function sigma = getAccelerometerInRunBiasSigma(this)
      sigma = feval(this.m, 'getAccelerometerInRunBiasSigma');
    end
    
    function tau = getAccelerometerInRunBiasStability(this)
      tau = feval(this.m, 'getAccelerometerInRunBiasStability');
    end
    
    function sigma = getAccelerometerTurnOnScaleSigma(this)
      sigma = feval(this.m, 'getAccelerometerTurnOnScaleSigma');
    end
    
    function sigma = getAccelerometerInRunScaleSigma(this)
      sigma = feval(this.m, 'getAccelerometerInRunScaleSigma');
    end
    
    function tau = getAccelerometerInRunScaleStability(this)
      tau = feval(this.m, 'getAccelerometerInRunScaleStability');
    end
  end
end
