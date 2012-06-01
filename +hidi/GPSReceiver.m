classdef GPSReceiver < hidi.Sensor
  methods (Static = true, Access = protected)
    function this = GPSReceiver()
    end
  end
  
  methods (Abstract = true, Access = public)
    longitude = getLongitude(this, n);
    latitude = getLatitude(this, n);
    height = getHeight(this, n);
    flag = hasPrecision(this);
    horizontal = getPrecisionHorizontal(this, n);
    vertical = getPrecisionVertical(this, n);
    circular = getPrecisionCircular(this, n);
  end 
end
