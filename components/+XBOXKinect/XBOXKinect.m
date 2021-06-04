classdef XBOXKinect < XBOXKinect.XBOXKinectConfig & hidi.DataContainer
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  properties (Constant = true, GetAccess = private)
    hasRef = false;
    bodyRef = [];
    noRefText = 'This data container has no reference trajectory.';
    kinectDescription = 'XBOX Kinect';
  end
  
  properties (Access = private)
    sensor
    sensorDescription
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'Provides data from an XBOX Kinect sensor using the libfreenect library.';
      end
      hidi.DataContainer.connect(name, @componentDescription, @XBOXKinect.XBOXKinect);
    end
  end
  
  methods (Access = public)
    function this = XBOXKinect(initialTime)
      this = this@hidi.DataContainer(initialTime);
      this.sensorDescription{1} = this.kinectDescription;
      this.sensor{1} = XBOXKinect.Kinect(initialTime);
    end
    
    function list = listSensors(this, type)
      K = numel(this.sensor);
      flag = false(K, 1);
      for k = 1:K
        if(isa(this.sensor{k}, type))
          flag(k) = true;
        end
      end
      list = hidi.SensorIndex(find(flag)-1);
    end
    
    function text = getSensorDescription(this, id)
      text = this.sensorDescription{id+1};
    end
    
    function obj = getSensor(this, id)
      obj = this.sensor{id+1};
    end
    
    function flag = hasReferenceTrajectory(this)
      flag = this.hasRef;
    end
    
    function x = getReferenceTrajectory(this)
      x = this.bodyRef;
      error(this.noRefText);
    end
  end
end
