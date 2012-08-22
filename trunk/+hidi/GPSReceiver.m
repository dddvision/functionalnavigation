classdef GPSReceiver < hidi.Sensor
  methods (Access = protected, Static = true)
    function this = GPSReceiver()
    end
  end
  
  methods (Access = public, Abstract = true)
    longitude = getLongitude(this, n);
    latitude = getLatitude(this, n);
    height = getHeight(this, n);
    flag = hasPrecision(this);
    horizontal = getHDOP(this, n);
    vertical = getVDOP(this, n);
    circular = getPDOP(this, n);
  end 
end
