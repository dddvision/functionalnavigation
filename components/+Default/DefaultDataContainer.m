classdef DefaultDataContainer < tom.DataContainer
  
  properties (Constant = true, GetAccess = private)
    hasRef = true;
    sensorDescription = {'Default sensor description.'};
  end
  
  properties (SetAccess = private, GetAccess = private)
    sensor
    referenceTrajectory
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'This default data container returns a default sensor and has a default trajectory.';
      end
      tom.DataContainer.connect(name, @componentDescription, @Default.DefaultDataContainer);
    end
  end
  
  methods (Access = public, Static = true)
    function this = DefaultDataContainer(initialTime)
      this = this@tom.DataContainer(initialTime);
      this.sensor = Default.DefaultSensor(initialTime);
      this.referenceTrajectory = Default.DefaultTrajectory(initialTime);
    end
  end
  
  methods (Access = public, Static = false)
    function list = listSensors(this, type)
      if(isa(this.sensor, type))
        list = tom.SensorIndex(0);
      else
        list = tom.SensorIndex(zeros(0, 1));
      end
    end
    
    function text = getSensorDescription(this, id)
      text = this.sensorDescription{id+1};
    end
        
    function obj = getSensor(this, id)
      obj = this.sensor(id+1);
    end
    
    function flag = hasReferenceTrajectory(this)
      flag = this.hasRef;
    end
    
    function x = getReferenceTrajectory(this)
      x = this.referenceTrajectory;
    end
  end
  
end
