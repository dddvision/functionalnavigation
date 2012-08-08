% This class defines a uniform interface to sensor data and ground truth
%
% NOTES
% A component can connect to multiple framework classes
classdef DataContainer < handle
  methods (Access = private, Static = true)
    % Storage for component descriptions
    function dL = pDescriptionList(name, cD)
      persistent descriptionList
      if(isempty(descriptionList))
        descriptionList = containers.Map;
      end
      if(nargin==2)
        descriptionList(name) = cD;
      else
        dL = descriptionList;
      end
    end

    % Storage for component factories
    function fL = pFactoryList(name, cF)
      persistent factoryList
      if(isempty(factoryList))
        factoryList = containers.Map;
      end
      if(nargin==2)
        factoryList(name) = cF;
      else
        fL = factoryList;
      end
    end
  end
  
  methods (Access = protected, Static = true)
    % Protected method to construct a singleton component instance
    %
    % @param[in] initialTime less than or equal to the time stamp of the first data node of any sensor
    %
    % NOTES
    % Each subclass constructor must initialize this base class
    % Initialize by calling this = this@hidi.DataContainer(initialTime);
    function this = DataContainer(initialTime)
      assert(isa(initialTime, 'double'));
    end
    
    % Establish connection between framework class and component
    %
    % @param[in] name component identifier, string
    % @param[in] cD   function that returns a user friendly description, function handle
    % @param[in] cF   function that can instantiate the subclass, function handle
    %
    % NOTES
    % The description may be truncated after a few hundred characters when displayed
    % The description should not contain line feed or return characters
    % Call this function from initialize()
    function connect(name, cD, cF)
      if(isa(cD, 'function_handle')&&...
         isa(cF, 'function_handle'))
         hidi.DataContainer.pDescriptionList(name, cD);
         hidi.DataContainer.pFactoryList(name, cF);
      end
    end
  end
      
  methods (Access = public, Static = true)
    % Check if a named subclass is connected with this base class
    %
    % @param[in] name component identifier, string
    % @param[in]      true if the subclass exists and is connected to this base class, bool
    %
    % NOTES
    % Do not shadow this function
    % A package directory identifying the component must in the environment path
    % Omit the '+' prefix when identifying package names
    function flag = isConnected(name)
      flag = false;
      className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];
      if(exist(className, 'class'))
        try
          feval([className, '.initialize'], name);
        catch err
          err.message;
        end  
        if(isKey(hidi.DataContainer.pFactoryList(name), name))
          flag = true;
        end
      end
    end
    
    % Get user friendly description of a component
    %
    % @param[in] name component identifier, string
    % @return         user friendly description, string
    %
    % NOTES
    % Do not shadow this function
    % If the component is not connected then the output is an empty string
    function text = description(name)
      text = '';
      if(hidi.DataContainer.isConnected(name))
        dL = hidi.DataContainer.pDescriptionList(name);
        text = feval(dL(name));
      end
    end
    
    % Public method to construct a singleton component instance
    %
    % @param[in] name component identifier, string
    % @param[in] initialTime less than or equal to the time stamp of the first data node of any sensor
    % @return         singleton object instance that should not be deleted, hidi.DataContainer
    %
    % NOTES
    % Do not shadow this function
    % Throws an error if the component is not connected
    function obj = create(name, initialTime)
      persistent identifier singleton
      assert(isa(initialTime, 'double'));
      if(hidi.DataContainer.isConnected(name))
        if(isempty(singleton))
          cF = hidi.DataContainer.pFactoryList(name);
          obj = feval(cF(name), initialTime);
          assert(isa(obj, 'hidi.DataContainer'));
          singleton = obj;
          identifier = name;
        else
          if(strcmp(name, identifier))
            obj = singleton;
          else
            error('This singleton class must receive the same ''name'' argument every time it is called');
          end
        end
      else
        error('The requested component is not connected');
      end
    end
  end
  
  methods (Access = public, Abstract = true, Static = true)
    % Initializes connections between a component and one or more framework classes
    %
    % @param[in] name component identifier, string
    %
    % NOTES
    % Implement this as a static function that calls connect()
    initialize(name);
  end
  
  methods (Access = public, Abstract = true)
    % List available sensors of a given class
    %
    % @param[in]  type class identifier, string
    % @param[out] list unique sensor identifiers, hidi.SensorIndex N-by-1
    %
    % NOTES
    % Sensors that inherit from the given class will also be included in the output list
    % To list all, use type='Sensor'
    list = listSensors(this, type);
    
    % Get sensor description
    %
    % @param[in] id zero-based index, hidi.SensorIndex
    % @return       user friendly sensor description, string
    %
    % NOTES
    % Description may be truncated after a few hundred characters when displayed
    % Description should be unique within a DataContainer
    % Avoid using line feed or return characters
    % Throws an exception if input index is out of range
    text = getSensorDescription(this, id);
    
    % Get instance of a Sensor
    %
    % @param[in] id zero-based index, hidi.SensorIndex
    % @return       object instance, hidi.Sensor
    %
    % NOTES
    % The specific subclass of the output depends on the given identifier
    % Throws an exception if input index is out of range
    obj = getSensor(this, id);
    
    % Check whether a refernce trajectory is available
    %
    % @return true if available and false otherwise
    flag = hasReferenceTrajectory(this);
    
    % Get reference trajectory
    %
    % @return object instance, tom.Trajectory
    %
    % NOTES
    % The body follows this trajectory while recording sensor data
    % Throws an exception if trajectory is not available
    x = getReferenceTrajectory(this);
  end
end
