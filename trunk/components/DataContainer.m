% This class defines a uniform interface to sensor data and ground truth
classdef DataContainer < handle
  
  methods (Access=protected,Static=true)
    % Protected method to construct a singleton component
    %
    % NOTES
    % Each subclass constructor must explicitly call this constructor 
    %   using the syntax this=this@DataContainer;
    function this=DataContainer
    end
    
    % Establish connection between framework class and component
    %
    % INPUT
    % name = component identifier, string
    % cD = function that returns a user friendly description, function handle
    % cF = function that can instantiate the subclass, function handle
    %
    % NOTES
    % The description may be truncated after a few hundred characters when displayed
    % The description should not contain line feed or return characters
    % A component can connect to multiple framework classes
    % (C++) Call this function prior to the invocation of main() using an initializer class
    % (MATLAB) Call this function from initialize()
    function connect(name,cD,cF)
      if(isa(cD,'function_handle')&&...
         isa(cF,'function_handle'))
         pDescriptionList(name,cD);
         pFactoryList(name,cF);
      end
    end
  end
      
  methods (Access=public,Static=true)
    % Check if a named subclass is connected with this base class
    %
    % INPUT
    % name = component identifier, string
    %
    % OUTPUT
    % flag = true if the subclass exists and is connected to this base class, logical scalar
    %
    % NOTES
    % Do not shadow this function
    % A package directory identifying the component must in the environment path
    % Omit the '+' prefix when identifying package names
    function flag=isConnected(name)
      flag=false;
      if(exist([name,'.',name],'class'))
        try
          feval([name,'.',name,'.initialize'],name);
        catch err
          err.message;
        end  
        if(isfield(pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    % Get user friendly description of a component
    %
    % INPUT
    % name = component identifier, string
    %
    % OUTPUT
    % text = user friendly description, string
    %
    % NOTES
    % Do not shadow this function
    % If the component is not connected then the output is an empty string
    function text=description(name)
      text='';
      if(DataContainer.isConnected(name))
        dL=pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    % Public method to construct a singleton component
    %
    % INPUT
    % name = package identifier, string
    %
    % OUTPUT
    % this = singleton object instance, DataContainer scalar
    %
    % NOTES
    % Do not shadow this function
    % Throws an error if the component is not connected
    function obj=factory(name)
      persistent singleton
      if(DataContainer.isConnected(name))
        if(isempty(singleton))
          cF=pFactoryList(name);
          obj=cF.(name)();
          assert(isa(obj,'DataContainer'));
          singleton=obj;
        else
          obj=singleton;
        end
      else
        error('DataContainer is not connected tothe requested component');
      end
    end
  end
  
  methods (Abstract=true,Access=protected,Static=true)
    % (MATLAB) Initializes connections between a component and one or more framework classes
    %
    % INPUT
    % name = component identifier, string
    initialize(name);
  end
  
  methods (Abstract=true,Access=public,Static=false)
    % List available sensors of a given class
    %
    % INPUT
    % type = class identifier, string
    %
    % OUTPUT
    % list = list of unique sensor identifiers, SensorIndex N-by-1
    %
    % NOTES
    % Sensors that inherit from the given class will also be included in the output list
    % To list all, use type='Sensor'
    list=listSensors(this,type);
    
    % Get sensor description
    %
    % INPUT
    % id = zero-based index, SensorIndex scalar
    %
    % OUTPUT
    % text = user friendly sensor description, string
    %
    % NOTES
    % Description may be truncated after a few hundred characters when displayed
    % Description should be unique within a DataContainer
    % Avoid using line feed or return characters
    % Throws an exception if input index is out of range
    text=getSensorDescription(this,id);

    % Get instance of a Sensor
    %
    % INPUT
    % id = zero-based index, SensorIndex scalar
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

% Storage for component descriptions
function dL=pDescriptionList(name,cD)
  persistent descriptionList
  if(nargin==2)
    descriptionList.(name)=cD;
  else
    dL=descriptionList;
  end
end

% Storage for component factories
function fL=pFactoryList(name,cF)
  persistent factoryList
  if(nargin==2)
    factoryList.(name)=cF;
  else
    fL=factoryList;
  end
end
