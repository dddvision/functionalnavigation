classdef Sensor < handle
  
  methods (Access = protected, Static = true)
    function this = Sensor(initialTime)
      assert(isa(initialTime, 'tom.WorldTime'));
    end
  end
  
  methods (Abstract = true, Access = public, Static = false)
    refresh(this, x);
    flag = hasData(this);
    n = first(this);
    n = last(this);
    time = getTime(this, n);
  end
  
end
