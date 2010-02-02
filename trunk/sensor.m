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
    
    % Get time stamp at a node
    %
    % INPUT
    % k = index, uint32 scalar
    %
    % OUTPUT
    % time = time stamp, double scalar
    %
    % NOTES
    % Time stamps must not decrease with increasing indices
    % Throws an exception if data at the node is invalid
    time=getTime(this,k);
    
    % Return index to the first data node
    %
    % INPUT
    % ka = index to first node, uint32 scalar
    %
    % NOTES
    % Returns empty if no data is available
    ka=first(this);
    
    % Return index to the last data node
    %
    % INPUT
    % ka = index to last node, uint32 scalar
    %
    % NOTES
    % Returns empty if no data is available
    kb=last(this);
  end
  
end
