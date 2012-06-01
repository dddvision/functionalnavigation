classdef Sensor < handle
  methods (Static = true, Access = protected)
    function this = Sensor()
    end
  end
  
  methods (Abstract = true, Access = public)
    refresh(this, varargin);
    flag = hasData(this);
    n = first(this);
    n = last(this);
    time = getTime(this, n);
  end
end
