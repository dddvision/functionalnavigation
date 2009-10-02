% NOTES
% TODO: handle invalid indices and other errors
classdef multiSensor
  
  methods (Access=protected)
    % Count number of sensor instances of a given class
    %
    % INPUT
    % type = class identifier, string
    %
    % OUTPUT
    % list = list of unique sensor identifiers for the given class, uint32 N-by-1
    %
    % NOTE
    % Sensors that inherit from the given class will also be included 
    list=listSensors(this,type);
    
    % Get sensor name
    %
    % INPUT
    % id = unique identifier of a sensor, uint32 scalar
    %
    % OUTPUT
    % name = sensor name, string
    name=getName(this,id);
    
    % Get instance of a sensor
    %
    % INPUT
    % id = unique identifier of a sensor, uint32 scalar
    %
    % OUTPUT
    % obj = sensor instance
    %
    % NOTE
    % The specific subclass of the output depends on the given identifier
    obj=getSensor(this,id);
  end
  
end
