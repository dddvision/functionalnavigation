classdef DataContainerDefault < hidi.DataContainer
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default data container no data.';
      end
      hidi.DataContainer.connect(name, @componentDescription, @hidi.DataContainerDefault);
    end
  end
  
  methods (Access = public, Static = true)
    function this = DataContainerDefault(initialTime)
      this = this@hidi.DataContainer(initialTime);
    end
  end
  
  methods (Access = public)
    function list = listSensors(this, type)
      assert(isa(this, 'hidi.DataContainer'));
      assert(isa(type, 'char'));
      list = repmat(hidi.SensorIndex(0), [0, 1]);
    end
    
    function text = getSensorDescription(this, id)
      assert(isa(this, 'hidi.DataContainer'));
      assert(isa(id, 'hidi.SensorIndex'));
      text = '';
      assert(isa(text, 'char'));
      error('This default data container has no data.');
    end
        
    function obj = getSensor(this, id)
      assert(isa(this, 'hidi.DataContainer'));
      assert(isa(id, 'hidi.SensorIndex'));
      obj = tom.Measure.create('tom', hidi.WorldTime(0), '');
      assert(isa(obj,'hidi.Sensor'));
      error('This default data container has no data.');
    end
    
    function flag = hasReferenceTrajectory(this)
      assert(isa(this, 'hidi.DataContainer'));
      flag = false;
    end
    
    function x = getReferenceTrajectory(this)
      assert(isa(this, 'hidi.DataContainer'));
      x = tom.DynamicModel.create('tom', hidi.WorldTime(0), '');
      assert(isa(x, 'tom.Trajectory'));
      error('This default data container has no data.');
    end
  end
end
