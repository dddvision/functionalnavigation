classdef Altimeter < hidi.Sensor
  methods (Abstract = true)
    altitude = getAltitude(this, n);
  end 
end
