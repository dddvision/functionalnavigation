classdef TrajectorySim < antbed.DataContainer

  properties (Constant = true, GetAccess = private)
    list = antbed.SensorIndex(zeros(0, 1));
    errorText = 'This data container has no sensors.';
    hasRef = true;
  end
  
  properties (Access = private)
    trajectory
  end
    
  methods (Access = public, Static = true)
    function initialize(name)
      function text = componentDescription
        text = 'Simulates a reference trajectory based on control points provided in a file.';
      end
      antbed.DataContainer.connect(name, @componentDescription, @TrajectorySim.TrajectorySim);
    end

    function this = TrajectorySim(initialTime)
      this = this@antbed.DataContainer(initialTime);
      this.trajectory = TrajectorySim.ReferenceTrajectory(initialTime);
    end
  end
    
  methods (Access = public)
    function list = listSensors(this, type)
      assert(isa(type, 'char'));
      list = this.list;
    end
    
    function text = getSensorDescription(this, id)
      assert(isa(id, 'antbed.SensorIndex'));
      text = '';
      error(this.errorText);
    end
    
    function obj = getSensor(this, id)
      assert(isa(id, 'antbed.SensorIndex'));
      obj = [];
      error(this.errorText);
    end
      
    function flag = hasReferenceTrajectory(this)
      flag = this.hasRef;
    end
    
    function x = getReferenceTrajectory(this)
      x = this.trajectory;
    end
  end
  
end
