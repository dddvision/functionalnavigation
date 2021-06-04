classdef TrajectorySim < hidi.DataContainer & TrajectorySim.TrajectorySimConfig
% Copyright 2011 Scientific Systems Company Inc., New BSD License

  properties (Constant = true, GetAccess = private)
    list = hidi.SensorIndex(zeros(0, 1));
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
      hidi.DataContainer.connect(name, @componentDescription, @TrajectorySim.TrajectorySim);
    end

    function this = TrajectorySim(initialTime)
      this = this@hidi.DataContainer(initialTime);
      filename = fullfile(fileparts(mfilename('fullpath')), this.tangentPoseFileName);
      [t, p, q, r, s] = readTangentPoseFile(filename, initialTime);
      t0 = t(1);
      p0 = repmat(p(:, 1), [1, size(p, 2)]);
      r0 = repmat(r(:, 1), [1, size(r, 2)]);
      t = t0+this.timeScale*(t-t0);
      p = p0+this.translationScale*(p-p0);
      r = r0+this.translationScale*(r-r0);
      this.trajectory = TrajectorySim.ReferenceTrajectory(t, p, q, r, s);
    end
  end
    
  methods (Access = public)
    function list = listSensors(this, type)
      assert(isa(type, 'char'));
      list = this.list;
    end
    
    function text = getSensorDescription(this, id)
      assert(isa(id, 'hidi.SensorIndex'));
      text = '';
      error(this.errorText);
    end
    
    function obj = getSensor(this, id)
      assert(isa(id, 'hidi.SensorIndex'));
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

function [t, p, q, r, s] = readTangentPoseFile(filename, initialTime)
  data = dlmread(filename);
  t = initialTime+data(:, 1)';
  p = data(:, 2:4)';
  q = data(:, 5:8)';
  r = data(:, 9:11)';
  s = data(:, 12:14)';
end
