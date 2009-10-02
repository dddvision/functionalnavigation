% NOTES
% All sensors use SI units (meters, seconds, radians)
% TODO: handle invalid indices and other errors
classdef sensor
  
  methods (Abstract=true)
    % Get sensor name
    %
    % OUTPUT
    % name = sensor name, string
    name=getName(this);
    
    % Return first and last indices of a consecutive list of data elements
    %
    % OUTPUT
    % ka = first valid data index, uint32 scalar
    % kb = last valid data index, uint32 scalar
    %
    % NOTES
    % Return values are empty when no data is available
    [ka,kb]=domain(this);
    
    % Get time stamp
    %
    % INPUT
    % k = data index, uint32 scalar
    %
    % OUTPUT
    % time = time stamp, double scalar
    %
    % NOTES
    % Time stamps must not decrease with increasing indices
    time=getTime(this,k);
    
    % Temporarily lock the data buffer of this sensor so that subsequent
    %   function calls will be deterministic
    lock(this);
    
    % Unlock the data buffer of this sensor so that new data can be added 
    %   and old data can expire
    unlock(this);
  end
  
end
