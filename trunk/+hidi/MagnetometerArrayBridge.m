 classdef MagnetometerArrayBridge < hidi.MagnetometerArray
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
  end
  
  methods (Access = public)
    function this = MagnetometerArrayBridge(m)
      this.m = m;
    end
    
    function refresh(this)
      feval(this.m, 'magnetometerArrayRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, 'magnetometerArrayHasData');
    end
    
    function n = first(this)
      n = feval(this.m, 'magnetometerArrayFirst');
    end
    
    function n = last(this)
      n = feval(this.m, 'magnetometerArrayLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, 'magnetometerArrayGetTime', n);
    end
    
    function field = getMagneticField(this, n, ax)
      field = feval(this.m, 'getMagneticField', n, ax);
    end
    
    function field = getMagneticFieldCalibrated(this, n, ax)
      field = feval(this.m, 'getMagneticFieldCalibrated', n, ax);
    end
  end
end
 