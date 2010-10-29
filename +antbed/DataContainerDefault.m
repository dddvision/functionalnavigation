classdef DataContainerDefault < antbed.DataContainer
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default data container no data.';
      end
      antbed.DataContainer.connect(name, @componentDescription, @antbed.DataContainerDefault);
    end
  end
  
  methods (Access = public, Static = true)
    function this = DataContainerDefault(initialTime)
      this = this@antbed.DataContainer(initialTime);
    end
  end
  
  methods (Access = public, Static = false)
    function list = listSensors(this, type)
      assert(isa(this, 'antbed.DataContainer'));
      assert(isa(type, 'char'));
      list = repmat(antbed.SensorIndex(0), [0, 1]);
    end
    
    function text = getSensorDescription(this, id)
      assert(isa(this, 'antbed.DataContainer'));
      assert(isa(id, 'antbed.SensorIndex'));
      text = '';
      assert(isa(text, 'char'));
      error('This default data container has no data.');
    end
        
    function obj = getSensor(this, id)
      assert(isa(this, 'antbed.DataContainer'));
      assert(isa(id, 'antbed.SensorIndex'));
      obj = tom.Measure.create('tom', tom.WorldTime(0), '');
      assert(isa(obj,'tom.Sensor'));
      error('This default data container has no data.');
    end
    
    function flag = hasReferenceTrajectory(this)
      assert(isa(this, 'antbed.DataContainer'));
      flag = false;
    end
    
    function x = getReferenceTrajectory(this)
      assert(isa(this, 'antbed.DataContainer'));
      x = tom.DynamicModel.create('tom', tom.WorldTime(0), '');
      assert(isa(x, 'tom.Trajectory'));
      error('This default data container has no data.');
    end
  end
  
end
