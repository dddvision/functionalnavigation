classdef Pedometer < hidi.Sensor
  methods (Static = true, Access = protected)
    flag = isComplete(this, node);
    magnitude = getMagnitude(this, node);
    sigma = getDeviation(this, node);
    stepLabel = getLabel(this, node);
  end
end
