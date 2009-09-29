classdef sensor
  
  % TODO: use exceptions for error handling
  methods (Access=public,Abstract=false)
    % Lock the sensor data
    lock(this);
    
    % Unlock the sensor data
    unlock(this);
    
    % Return first and last valid indices
    %
    % OUTPUT
    % a = first valid node index, uint32 scalar
    % b = last valid node index, uint32 scalar
    %
    % NOTES
    % Returns empty when no nodes are available
    [a,b]=domain(this);
    
    % Get time stamp
    %
    % INPUT
    % k = node index, uint32 scalar
    %
    % OUTPUT
    % time = time stamp, double scalar
    %
    % NOTES
    % Time stamps must not decrease with increasing indices
    time=getTime(this,k);
  end
  
end
