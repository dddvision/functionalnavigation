classdef DistanceTraveled < tom.MeasureBridge
  methods (Access = public)
    function this = DistanceTraveled(initialTime, uri)
      this = this@tom.MeasureBridge('DistanceTraveled', initialTime, uri);
    end
  end
end
