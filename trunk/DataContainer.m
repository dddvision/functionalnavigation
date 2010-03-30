% This class defines a uniform interface to sensor data and ground truth
classdef DataContainer < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='DataContainer';
  end
  
  methods (Static=true,Access=public)
    % Instantiate a singleton subclass by name
    %
    % INPUT
    % pkg = package identifier, string
    %
    % OUTPUT
    % this = object instance, DataContainer scalar
    %
    % NOTES
    % The package directory must in the environment path
    % (MATLAB) Omit the '+' prefix when identifying package names
    % (MATLAB) The singleton design pattern is implemented by deriving from
    %   the handle class and using persistence to keep a unique instance
    function this=factory(pkg)
      persistent singleton
      if(isempty(singleton))
        this=feval([pkg,'.',pkg]);
        assert(isa(this,'DataContainer'));
        singleton=this;
      else
        this=singleton;
      end
    end
  end
  
  methods (Access=protected)
    % Construct a DataContainer
    %
    % NOTES
    % Each subclass constructor must explicitly call this constructor 
    %   using the syntax this=this@DataContainer;
    function this=DataContainer
    end
  end  

  methods (Abstract=true) 
    % List available sensors of a given class
    %
    % INPUT
    % type = class identifier, string
    %
    % OUTPUT
    % list = list of unique sensor identifiers, uint32 N-by-1
    %
    % NOTES
    % Sensors that inherit from the given class will also be included in the output list
    % To list all sensors, use type='sensor'
    list=listSensors(this,type);
    
    % Get sensor name
    %
    % INPUT
    % id = zero-based index, uint32 scalar
    %
    % OUTPUT
    % name = sensor name, string
    %
    % NOTES
    % The name does not need to be unique, but a specific name helps the 
    %   user to configure the framework.
    % Throws an exception if input index is out of range
    name=getSensorName(this,id);

    % Get instance of a Sensor
    %
    % INPUT
    % id = zero-based index, uint32 scalar
    %
    % OUTPUT
    % obj = object instance, Sensor scalar
    %
    % NOTES
    % The specific subclass of the output depends on the given identifier
    % Throws an exception if input index is out of range
    obj=getSensor(this,id);
    
    % Check whether a refernce trajectory is available
    %
    % OUTPUT
    % flag = true if available, false otherwise, bool scalar
    flag=hasReferenceTrajectory(this);
    
    % Get reference trajectory
    %
    % OUTPUT
    % x = object instance, Trajectory scalar
    %
    % NOTES
    % The body follows this trajectory while recording sensor data
    % Throws an exception if trajectory is not available
    x=getReferenceTrajectory(this);
  end
  
end
