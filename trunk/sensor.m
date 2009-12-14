% This class defines methods shared by synchronously time-stamped sensors
% Using GPS time referenced to zero at 1980-00-06T00:00:00 GMT
%   GPS time is a few seconds ahead of UTC
% All sensors use SI units and radians unless otherwise stated
classdef sensor < handle
  
  methods (Abstract=true)
    % Incorporate new data and allow old data to expire
    %
    % OUTPUT
    % status = true if any data is available and false otherwise, logical scalar
    %
    % NOTES
    % Does not wait for hardware events
    status=refresh(this);
    
    % Return the smallest and largest data indices
    %
    % OUTPUT
    % ka = smallest index, uint32 scalar
    % kb = largest index, uint32 scalar
    %
    % NOTES
    % Throws an exception if no data is available
    [ka,kb]=getNodeBounds(this);
    
    % Get time stamp at a node
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
  end
  
end
