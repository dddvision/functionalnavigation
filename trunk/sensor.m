% NOTES
% All sensors use SI units (meters, seconds, radians)
% TODO: deal with invalid indices and other errors
classdef sensor < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='sensor';  
  end
  
  methods (Abstract=true)
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
    
    % Temporarily lock the data buffer of this sensor
    %
    % NOTES
    % This causes subsequent function calls to be deterministic
    % Blocks until active buffer transactions are completed
    lock(this);
    
    % Unlock the data buffer of this sensor
    %
    % NOTES
    % This allows new data to be added and old data to expire
    % Blocks until active buffer transactions are completed
    unlock(this);
  end
  
end
