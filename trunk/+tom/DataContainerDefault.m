classdef DataContainerDefault < tom.DataContainer
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default data container has a default trajectory but no sensors.';
      end
      tom.DataContainer.connect(name, @componentDescription, @tom.DataContainerDefault);
    end
  end
  
  methods (Access = public, Static = true)
    function this = DataContainerDefault(initialTime)
      this = this@tom.DataContainer(initialTime);
    end
  end
  
  methods (Access = public, Static = false)
    function list = listSensors(this, type)
      assert(isa(this, 'tom.DataContainer'));
      assert(isa(type, 'char'));
      list = repmat(tom.SensorIndex(0), [0, 1]);
    end
    
    function text = getSensorDescription(this, id)
      assert(isa(this, 'tom.DataContainer'));
      assert(isa(id, 'tom.SensorIndex'));
      text = '';
      assert(isa(text, 'char'));
      error('The default data container has no sensors.');
    end
        
    function obj = getSensor(this, id)
      assert(isa(this, 'tom.DataContainer'));
      assert(isa(id, 'tom.SensorIndex'));
      obj = tom.SensorDefault(tom.WorldTime(0));
      assert(isa(obj,'tom.Sensor'));
      error('The default data container has no sensors.');
    end
    
    function flag = hasReferenceTrajectory(this)
      assert(isa(this, 'tom.DataContainer'));
      flag = true;
    end
    
    function x = getReferenceTrajectory(this)
      assert(isa(this, 'tom.DataContainer'));
      x = tom.TrajectoryDefault(tom.WorldTime(0));
    end
  end
  
end
