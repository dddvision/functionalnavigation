classdef GPSReceiver < hidi.Sensor
  methods (Abstract = true)
    longitude = getLongitude(this, n);
    latitude = getLatitude(this, n);
    height = getHeight(this, n);
    flag = hasPrecision(this);
    horizontal = getPrecisionHorizontal(this, n);
    vertical = getPrecisionVertical(this, n);
    circular = getPrecisionCircular(this, n);
  end 
end
