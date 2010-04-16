classdef SensorIndex < uint32
  methods (Access=public)
    function this=SensorIndex(varargin)
      this=this@uint32(varargin{:});
    end
  end
end
