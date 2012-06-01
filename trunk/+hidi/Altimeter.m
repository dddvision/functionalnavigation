classdef Altimeter < hidi.Sensor
  methods (Static = true, Access = protected)
    function this = Altimeter()
    end
  end
  
  methods (Abstract = true, Access = public)
    altitude = getAltitude(this, n);
  end 
end
