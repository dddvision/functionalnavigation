% This class defines a uniform interface to sensor data and ground truth
classdef dataContainer < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='dataContainer';
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
    % Sensors that inherit from the given class will also be included in
    %   the output list
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

    % Get instance of a sensor
    %
    % INPUT
    % id = zero-based index, uint32 scalar
    %
    % OUTPUT
    % obj = sensor instance
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
    % x = trajectory instance
    %
    % NOTES
    % The body follows this trajectory while recording sensor data
    % Throws an exception if trajectory is not available
    x=getReferenceTrajectory(this);
  end
  
end
