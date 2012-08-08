classdef Sensor < handle
  methods (Access = protected, Static = true)
    function this = Sensor()
    end
  end
  
  methods (Access = public, Abstract = true)
    refresh(this, varargin);
    flag = hasData(this);
    n = first(this);
    n = last(this);
    time = getTime(this, n);
  end
end
