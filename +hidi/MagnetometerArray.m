classdef MagnetometerArray < hidi.Sensor
  methods (Abstract = true)
    field = getMagneticField(this, n, ax);
  end
end
