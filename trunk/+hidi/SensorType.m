classdef SensorType
  properties (Constant = true, GetAccess = public)
    ACCELEROMETER_ARRAY = uint32(0);
    ALTIMETER = uint32(1);
    CAMERA = uint32(2);
    GPS_RECEIVER = uint32(3);
    GYROSCOPE_ARRAY = uint32(4);
    MAGNETOMETER_ARRAY = uint32(5);
    PEDOMETER = uint32(6);
  end
end
