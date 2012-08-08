classdef MagnetometerArray < hidi.Sensor
  methods (Access = protected, Static = true)
    function this = MagnetometerArray()
    end
  end
  
  methods (Access = public, Abstract = true)
    field = getMagneticField(this, n, ax);
  end
end
