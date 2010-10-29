classdef DataContainerDefault < tom.DataContainer
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default data container no data.';
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
      error('This default data container has no data.');
    end
        
    function obj = getSensor(this, id)
      assert(isa(this, 'tom.DataContainer'));
      assert(isa(id, 'tom.SensorIndex'));
      obj = tom.Measure.create('tom', tom.WorldTime(0), '');
      assert(isa(obj,'tom.Sensor'));
      error('This default data container has no data.');
    end
    
    function flag = hasReferenceTrajectory(this)
      assert(isa(this, 'tom.DataContainer'));
      flag = false;
    end
    
    function x = getReferenceTrajectory(this)
      assert(isa(this, 'tom.DataContainer'));
      x = tom.DynamicModel.create('tom', tom.WorldTime(0), '');
      assert(isa(x, 'tom.Trajectory'));
      error('This default data container has no data.');
    end
  end
  
end
