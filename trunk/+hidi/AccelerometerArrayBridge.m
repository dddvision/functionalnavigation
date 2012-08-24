classdef AccelerometerArrayBridge < hidi.AccelerometerArray
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    h % handle to C++ object
  end
  
  methods (Access = public)
    function this = AccelerometerArrayBridge(m, h)
      if(nargin>0)
        this.m = m;
        this.h = h;
      end
    end
    
    function refresh(this)
      feval(this.m, this.h, 'accelerometerArrayRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, this.h, 'accelerometerArrayHasData');
    end
    
    function n = first(this)
      n = feval(this.m, this.h, 'accelerometerArrayFirst');
    end
    
    function n = last(this)
      n = feval(this.m, this.h, 'accelerometerArrayLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, this.h, 'accelerometerArrayGetTime', n);
    end
    
    function force = getSpecificForce(this, n, ax)
      force = feval(this.m, this.h, 'getSpecificForce', n, ax);
    end
    
    function walk = getAccelerometerRandomWalk(this)
      walk = feval(this.m, this.h, 'getAccelerometerRandomWalk');
    end
    
    function sigma = getAccelerometerTurnOnBiasSigma(this)
      sigma = feval(this.m, this.h, 'getAccelerometerTurnOnBiasSigma');
    end
    
    function sigma = getAccelerometerInRunBiasSigma(this)
      sigma = feval(this.m, this.h, 'getAccelerometerInRunBiasSigma');
    end
    
    function tau = getAccelerometerInRunBiasStability(this)
      tau = feval(this.m, this.h, 'getAccelerometerInRunBiasStability');
    end
    
    function sigma = getAccelerometerTurnOnScaleSigma(this)
      sigma = feval(this.m, this.h, 'getAccelerometerTurnOnScaleSigma');
    end
    
    function sigma = getAccelerometerInRunScaleSigma(this)
      sigma = feval(this.m, this.h, 'getAccelerometerInRunScaleSigma');
    end
    
    function tau = getAccelerometerInRunScaleStability(this)
      tau = feval(this.m, this.h, 'getAccelerometerInRunScaleStability');
    end
  end
end
