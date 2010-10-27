classdef SensorDefault < tom.Sensor
  
  methods (Access = public, Static = true)
    function this = SensorDefault(initialTime)
      this = this@tom.Sensor(initialTime);
    end
  end
  
  methods (Access = public, Static = false)
    function refresh(this, x)
      assert(isa(this, 'tom.Sensor'));
      assert(isa(x, 'tom.Trajectory'));
    end
    
    function flag = hasData(this)
      assert(isa(this, 'tom.Sensor'));
      flag = false;
    end
    
    function n = first(this)
      assert(isa(this, 'tom.Sensor'));
      n = uint32(0);
      assert(isa(n, 'uint32'));
      error('The default sensor has no data.');
    end
    
    function n = last(this)
      assert(isa(this, 'tom.Sensor'));
      n = uint32(0);
      assert(isa(n, 'uint32'));
      error('The default sensor has no data.');
    end
    
    function time = getTime(this, n)
      assert(isa(this, 'tom.Sensor'));
      assert(isa(n, 'uint32'));
      time = tom.WorldTime(0);
      assert(isa(time, 'tom.WorldTime'));
      error('The default sensor has no data.');
    end
  end
  
end
