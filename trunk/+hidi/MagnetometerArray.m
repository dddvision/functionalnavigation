classdef MagnetometerArray < hidi.Sensor
  methods (Static = true, Access = protected)
    function this = MagnetometerArray()
    end
  end
  
  methods (Abstract = true, Access = public)
    field = getMagneticField(this, n, ax);
  end
end
