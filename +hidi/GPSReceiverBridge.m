classdef GPSReceiverBridge < hidi.GPSReceiver
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    h % handle to C++ object
  end
  
  methods (Access = public)
    function this = GPSReceiverBridge(m, h)
      if(nargin>0)
        this.m = m;
        this.h = h;
      end
    end
    
    function refresh(this)
      feval(this.m, this.h, 'gpsReceiverRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, this.h, 'gpsReceiverHasData');
    end
    
    function n = first(this)
      n = feval(this.m, this.h, 'gpsReceiverFirst');
    end
    
    function n = last(this)
      n = feval(this.m, this.h, 'gpsReceiverLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, this.h, 'gpsReceiverGetTime', n);
    end
    
    function longitude = getLongitude(this, n)
      longitude = feval(this.m, this.h, 'getLongitude', n);
    end

    function latitude = getLatitude(this, n)
      latitude = feval(this.m, this.h, 'getLatitude', n);
    end
    
    function height = getHeight(this, n)
      height = feval(this.m, this.h, 'getHeight', n);
    end
    
    function flag = hasPrecision(this)
      flag = feval(this.m, this.h, 'hasPrecision');
    end
    
    function horizontal = getHDOP(this, n)
      horizontal = feval(this.m, this.h, 'getHDOP', n);
    end
    
    function vertical = getVDOP(this, n)
      vertical = feval(this.m, this.h, 'getVDOP', n);
    end
    
    function circular = getPDOP(this, n)
      circular = feval(this.m, this.h, 'getPDOP', n);
    end
  end
end
