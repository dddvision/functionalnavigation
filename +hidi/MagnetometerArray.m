classdef MagnetometerArray < hidi.Sensor
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  methods (Access = protected, Static = true)
    function this = MagnetometerArray()
    end
  end
  
  methods (Access = public, Abstract = true)
    field = getMagneticField(this, n, ax);
  end
end
