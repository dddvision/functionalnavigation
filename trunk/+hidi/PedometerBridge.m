classdef PedometerBridge < hidi.Pedometer
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    h % handle to C++ object
  end
  
  methods (Access = public)
    function this = PedometerBridge(m, h)
      if(nargin>0)
        this.m = m;
        this.h = h;
      end
    end
    
    function refresh(this)
      feval(this.m, this.h, 'pedometerRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, this.h, 'pedometerHasData');
    end
    
    function n = first(this)
      n = feval(this.m, this.h, 'pedometerFirst');
    end
    
    function n = last(this)
      n = feval(this.m, this.h, 'pedometerLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, this.h, 'pedometerGetTime', n);
    end
    
    function flag = isStepComplete(this, n)
      flag = feval(this.m, this.h, 'isStepComplete', n);
    end
    
    function magnitude = getStepMagnitude(this, n)
      magnitude = feval(this.m, this.h, 'getStepMagnitude', n);
    end
    
    function deviation = getStepDeviation(this, n)
      deviation = feval(this.m, this.h, 'getStepDeviation', n);
    end
    
    function stepID = getStepID(this, n)
      stepID = feval(this.m, this.h, 'getStepID', n);
    end
  end
end
