% This class represents an index of a Sensor object in a DataContainer
% Copyright 2011 Scientific Systems Company Inc., New BSD License
classdef SensorIndex < uint32
  
  methods (Access = public)
    function this = SensorIndex(s)
      this = this@uint32(s);
    end
  end
  
end
