classdef DistanceTraveled < tom.MeasureBridge
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  methods (Access = public)
    function this = DistanceTraveled(initialTime, uri)
      this = this@tom.MeasureBridge('DistanceTraveled', initialTime, uri);
    end
  end
end
