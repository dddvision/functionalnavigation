classdef SensorType
  properties (Constant = true, GetAccess = public)
    ACCELEROMETER_ARRAY = uint32(0);
    GYROSCOPE_ARRAY = uint32(1);
    MAGNETOMETER_ARRAY = uint32(2);
    ALTIMETER = uint32(3);
    GPS_RECEIVER = uint32(4);
    PEDOMETER = uint32(5);
  end
end
