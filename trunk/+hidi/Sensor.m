classdef Sensor < handle
  methods (Access = protected, Static = true)
    function this = Sensor()
    end
  end
  
  methods (Access = public, Abstract = true)
    refresh(this, varargin);
    flag = hasData(this);
    node = first(this);
    node = last(this);
    time = getTime(this, node);
  end
end
