% This class defines methods shared by synchronously time-stamped sensors
% Using GPS time referenced to zero at 1980-00-06T00:00:00 GMT
%   GPS time is a few seconds ahead of UTC
% All sensors use SI units and radians unless otherwise stated
classdef sensor < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='sensor';  
  end
  
  methods (Abstract=true)
    % Return first and last indices of a consecutive list of data elements
    %
    % OUTPUT
    % a = first valid data index, uint32 scalar
    % b = last valid data index, uint32 scalar
    %
    % NOTES
    % Return values are empty when no data is available
    % Throws an exception if sensor is unlocked
    [a,b]=dataDomain(this);
    
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
    % Throws an exception if data index is invalid
    time=getTime(this,k);
    
    % Lock the data buffer so that other member functions will be deterministic
    %
    % OUTPUT
    % isLocked = true if successful and false otherwise, logical scalar
    %
    % NOTES
    % Returns false if data is unavailable
    % Does not wait for hardware events
    isLocked=lock(this);
    
    % Unlock the data buffer so that new data can be added and old data can expire
    %
    % OUTPUT
    % isUnlocked = true if successful and false otherwise, logical scalar
    %
    % NOTES
    % Returns true if data is unavailable
    % Does not wait for hardware events
    isUnlocked=unlock(this);
  end
  
end
