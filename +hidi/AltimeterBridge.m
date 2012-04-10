classdef AltimeterBridge < hidi.Altimeter
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    h % handle to C++ object
  end
  
  methods (Access = public)
    function this = AltimeterBridge(m, h)
      if(nargin>0)
        this.m = m;
        this.h = h;
      end
    end
    
    function refresh(this)
      feval(this.m, this.h, 'altimeterRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, this.h, 'altimeterHasData');
    end
    
    function n = first(this)
      n = feval(this.m, this.h, 'altimeterFirst');
    end
    
    function n = last(this)
      n = feval(this.m, this.h, 'altimeterLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, this.h, 'altimeterGetTime', n);
    end
    
    function altitude = getAltitude(this, n)
      altitude = feval(this.m, this.h, 'getAltitude', n);
    end
  end
end
