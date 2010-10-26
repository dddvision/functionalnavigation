classdef Sensor < tom.Sensor
  
  properties (Constant = true, GetAccess = private)
    hasDataFlag = false;
    noDataText = 'The default sensor has no data.';
  end
  
  methods (Access = public, Static = true)
    function this = Sensor(initialTime)
      this = this@tom.Sensor(initialTime);
    end
  end
  
  methods (Access = public, Static = false)
    function refresh(this, x)
      assert(isa(this, 'tom.Sensor'));
      assert(isa(x, 'tom.Trajectory'));
    end
    
    function flag = hasData(this)
      flag = this.hasDataFlag;
    end
    
    function n = first(this)
      n = [];
      error(this.noDataText);
    end
    
    function n = last(this)
      n = [];
      error(this.noDataText);
    end
    
    function time = getTime(this, n)
      assert(isa(n,'uint32'));
      time = [];
      error(this.noDataText);
    end
  end
  
end
