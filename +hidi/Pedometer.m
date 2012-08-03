classdef Pedometer < hidi.Sensor
  methods (Static = true, Access = protected)
    function this = Pedometer()
    end
  end
  
  methods (Abstract = true, Access = protected)
    flag = isComplete(this, node);
    magnitude = getMagnitude(this, node);
    sigma = getDeviation(this, node);
    stepID = getStepID(this, node);
  end
end
