classdef AltimeterBridge < hidi.Altimeter
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
  end
  
  methods (Access = public)
    function this = AltimeterBridge(m)
      this.m = m;
    end
    
    function refresh(this)
      feval(this.m, 'altimeterRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, 'altimeterHasData');
    end
    
    function n = first(this)
      n = feval(this.m, 'altimeterFirst');
    end
    
    function n = last(this)
      n = feval(this.m, 'altimeterLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, 'altimeterGetTime', n);
    end
    
    function altitude = getAltitude(this, n)
      altitude = feval(this.m, 'getAltitude', n);
    end
  end
end
