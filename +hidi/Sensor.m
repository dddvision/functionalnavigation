classdef Sensor < handle
  methods (Abstract = true, Access = public)
    refresh(this, varargin);
    flag = hasData(this);
    n = first(this);
    n = last(this);
    time = getTime(this, n);
  end
end
