classdef GPSReceiverBridge < hidi.GPSReceiver
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
  end
  
  methods (Access = public)
    function this = GPSReceiverBridge(m)
      this.m = m;
    end
    
    function refresh(this)
      feval(this.m, 'gpsReceiverRefresh');
    end
    
    function flag = hasData(this)
      flag = feval(this.m, 'gpsReceiverHasData');
    end
    
    function n = first(this)
      n = feval(this.m, 'gpsReceiverFirst');
    end
    
    function n = last(this)
      n = feval(this.m, 'gpsReceiverLast');
    end
    
    function time = getTime(this, n)
      time = feval(this.m, 'gpsReceiverGetTime', n);
    end
    
    function longitude = getLongitude(this, n)
      longitude = feval(this.m, 'getLongitude', n);
    end

    function latitude = getLatitude(this, n)
      latitude = feval(this.m, 'getLatitude', n);
    end
    
    function height = getHeight(this, n)
      height = feval(this.m, 'getHeight', n);
    end
    
    function flag = hasPrecision(this)
      flag = feval(this.m, 'hasPrecision');
    end
    
    function horizontal = getPrecisionHorizontal(this, n)
      horizontal = feval(this.m, 'getPrecisionHorizontal', n);
    end
    
    function vertical = getPrecisionVertical(this, n)
      vertical = feval(this.m, 'getPrecisionVertical', n);
    end
    
    function circular = getPrecisionCircular(this, n)
      circular = feval(this.m, 'getPrecisionCircular', n);
    end
  end
end
