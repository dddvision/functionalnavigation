% This class represents an index of a Sensor object in a DataContainer
% Public Domain
classdef SensorIndex < uint32
  
  methods (Access = public)
    function this = SensorIndex(s)
      this = this@uint32(s);
    end
  end
  
end
