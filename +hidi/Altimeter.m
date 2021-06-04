classdef Altimeter < hidi.Sensor
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  methods (Access = protected, Static = true)
    function this = Altimeter()
    end
  end
  
  methods (Access = public, Abstract = true)
    altitude = getAltitude(this, n);
  end 
end
