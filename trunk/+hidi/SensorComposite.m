classdef SensorComposite
  properties (GetAccess = private, SetAccess = private)
    sensor
    sensorLabel
  end
  
  methods (Access = public)
    function this = SensorComposite(package)
      this.sensor = {};
      this.sensorLabel = {};
    
      accelerometer = package.getAccelerometerArray();
      altimeter = package.getAltimeter();
      gpsReceiver = package.getGPSReceiver();
      gyroscope = package.getGyroscopeArray();
      magnetometer = package.getMagnetometerArray();

      for s = uint32((1:numel(accelerometer))-1)
        for a = uint32(0:2)
          this.sensor{end+1} = hidi.GenericSensor(hidi.SensorType.ACCELEROMETER_ARRAY, accelerometer{s+1}, a);
          this.sensorLabel{end+1} = ['Accelerometer[', num2str(s), '][', num2str(a), ']'];
        end
      end
      for s = uint32((1:numel(altimeter))-1)
        this.sensor{end+1} = hidi.GenericSensor(hidi.SensorType.ALTIMETER, altimeter{s+1}, uint32(0));
        this.sensorLabel{end+1} = ['Altimeter[', num2str(s), ']'];
      end
      for s = uint32((1:numel(gpsReceiver))-1)
        for a = uint32(0:2)
          this.sensor{end+1} = hidi.GenericSensor(hidi.SensorType.GPS_RECEIVER, gpsReceiver{s+1}, a);
          this.sensorLabel{end+1} = ['GPSReceiver[', num2str(s), '][', num2str(a), ']'];
        end
      end
      for s = uint32((1:numel(gyroscope))-1)
        for a = uint32(0:2)
          this.sensor{end+1} = hidi.GenericSensor(hidi.SensorType.GYROSCOPE_ARRAY, gyroscope{s+1}, a);
          this.sensorLabel{end+1} = ['Gyroscope[', num2str(s), '][', num2str(a), ']'];
        end
      end
      for s = uint32((1:numel(magnetometer))-1)
        for a = uint32(0:2)
          this.sensor{end+1} = hidi.GenericSensor(hidi.SensorType.MAGNETOMETER_ARRAY, magnetometer{s+1}, a);
          this.sensorLabel{end+1} = ['Magnetometer[', num2str(s), '][', num2str(a), ']'];
        end
      end
    end
    
    function num = numSensors(this)
      num = uint32(numel(this.sensor));
    end
    
    function s = getSensor(this, compositeIndex)
      assert(isa(compositeIndex, 'uint32'));
      s = this.sensor{compositeIndex+1};
    end
    
    function label = getLabel(this, compositeIndex)
      assert(isa(compositeIndex, 'uint32'));
      label = this.sensorLabel{compositeIndex+1};
    end
  end
end
