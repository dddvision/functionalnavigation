% NOTES
% TODO: handle invalid indices and other errors
classdef sensorContainer
  
  properties (Constant=true,GetAccess=public)
    baseClass='sensorContainer';
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
    % NOTE
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
    % NOTE
    % The name does not need to be unique, but a specific name helps the 
    %   user to configure the framework.
    name=getName(this,id);

    % Get instance of a sensor
    %
    % INPUT
    % id = zero-based index, uint32 scalar
    %
    % OUTPUT
    % obj = sensor instance
    %
    % NOTE
    % The specific subclass of the output depends on the given identifier
    obj=getSensor(this,id);
  end
  
end
