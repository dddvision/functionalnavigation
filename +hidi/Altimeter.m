classdef Altimeter < hidi.Sensor
  methods (Access = protected, Static = true)
    function this = Altimeter()
    end
  end
  
  methods (Access = public, Abstract = true)
    altitude = getAltitude(this, n);
  end 
end
