% This class defines a uniform interface to sensor data and ground truth
classdef DataContainer < handle
  
  methods (Static=true,Access=public)
    % Framework class identifier
    %
    % OUTPUT
    % text = name of the framework class, string
    function text=frameworkClass
      text='DataContainer';
    end
    
    % Public method to construct a singleton DataContainer
    %
    % INPUT
    % pkg = package identifier, string
    %
    % OUTPUT
    % this = object instance, DataContainer scalar
    %
    % NOTES
    % Do not shadow this function
    % The package directory must in the environment path
    % (MATLAB) Omit the '+' prefix when identifying package names
    % (MATLAB) The singleton design pattern is implemented by deriving from
    %   the handle class and using persistence to keep a unique instance
    function this=factory(pkg)
      persistent singleton
      subclass=[pkg,'.',pkg];
      if(isempty(singleton))
        this=feval(subclass);
        assert(isa(this,'DataContainer'));
        singleton=this;
      elseif(isa(singleton,subclass))
        this=singleton;
      else
        error('Cannot change subclass of singleton data container after instantiation.');
      end
    end
  end
  
  methods (Access=protected)
    % Protected method to construct a singleton DataContainer
    %
    % NOTES
    % Each subclass constructor must explicitly call this constructor 
    %   using the syntax this=this@DataContainer;
    function this=DataContainer
    end
  end

  methods (Abstract=true)
    % Get container description
    %
    % OUTPUT
    % text = user friendly sensor description, string
    %
    % NOTES
    % Description may be truncated after a few hundred characters when displayed
    text=getDescription(this);    
    
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
    % To list all, use type='Sensor'
    list=listSensors(this,type);
    
    % Get sensor description
    %
    % INPUT
    % id = zero-based index, uint32 scalar
    %
    % OUTPUT
    % text = user friendly sensor description, string
    %
    % NOTES
    % Description may be truncated after a few hundred characters when displayed
    % Description should be unique within a DataContainer
    % Throws an exception if input index is out of range
    text=getSensorDescription(this,id);

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
