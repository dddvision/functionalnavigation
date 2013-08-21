classdef GenericSensor < hidi.Sensor
  properties (GetAccess = private, SetAccess = private)
    sensorType
    sensor
    axisIndex
  end 
  
  methods (Access = public)
    function this = GenericSensor(sensorType, sensor, axisIndex)
      this.sensorType = sensorType;
      this.sensor = sensor;
      this.axisIndex = axisIndex;
    end
    
    function refresh(this)
      assert(isa(this, 'hidi.Sensor'));
    end
  
    function flag = hasData(this)
      flag = this.sensor.hasData();
    end

    function node = first(this)
      node = this.sensor.first();
    end

    function node = last(this)
      node = this.sensor.last();
    end

    function time = getTime(this, node)
      time = this.sensor.getTime(node);
    end

    function data = getData(this, node)
      switch(this.sensorType)
        case hidi.SensorType.ACCELEROMETER_ARRAY
          data = this.sensor.getSpecificForce(node, this.axisIndex);
        case hidi.SensorType.ALTIMETER
          data = this.sensor.getAltitude(node);
        case hidi.SensorType.GPS_RECEIVER
          switch(this.axisIndex)
            case 0
              data = this.sensor.getLongitude(node);
            case 1
              data = this.sensor.getLatitude(node);
            case 2
              data = this.sensor.getHeight(node);
            otherwise
              error('ExtractNorms: Sensor axis index out of range.');
          end
        case hidi.SensorType.GYROSCOPE_ARRAY
          data = this.sensor.getAngularRate(node, this.axisIndex);
        case hidi.SensorType.MAGNETOMETER_ARRAY
          data = this.sensor.getMagneticField(node, this.axisIndex);
        otherwise
          error('ExtractNorms: Invalid sensor type.');
      end
    end
  end
end
