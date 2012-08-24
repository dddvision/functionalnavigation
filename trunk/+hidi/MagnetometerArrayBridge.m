 classdef MagnetometerArrayBridge < hidi.MagnetometerArray
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    h % handle to C++ object
  end
  
  methods (Access = public)
    function this = MagnetometerArrayBridge(m, h)
      if(nargin>0)
        this.m = m;
        this.h = h;
      end
    end
    
    function refresh(this)
      feval(this.m, this.h, 'magnetometerArrayRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, this.h, 'magnetometerArrayHasData');
    end
    
    function n = first(this)
      n = feval(this.m, this.h, 'magnetometerArrayFirst');
    end
    
    function n = last(this)
      n = feval(this.m, this.h, 'magnetometerArrayLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, this.h, 'magnetometerArrayGetTime', n);
    end
    
    function field = getMagneticField(this, n, ax)
      field = feval(this.m, this.h, 'getMagneticField', n, ax);
    end
  end
end
 