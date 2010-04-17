% This class defines methods shared by synchronously time-stamped sensors
% Using GPS time referenced to zero at 1980-00-06T00:00:00 GMT
%   GPS time is a few seconds ahead of UTC
% All sensors use SI units and radians unless otherwise stated
classdef Sensor < handle
  
  methods (Abstract=true)
    % Incorporate new data and allow old data to expire
    %
    % NOTES
    % Does not block or wait for hardware events
    refresh(this);
    
    % Check whether data is available
    %
    % OUTPUT
    % flag = true if any data is available and false otherwise, logical scalar
    flag=hasData(this);

    % Return index to the first data node
    %
    % INPUT
    % ka = index to first node, uint32 scalar
    %
    % NOTES
    % Throws an exception if no data is available
    ka=first(this);
    
    % Return index to the last data node
    %
    % INPUT
    % ka = index to last node, uint32 scalar
    %
    % NOTES
    % Throws an exception if no data is available
    kb=last(this);

    % Get time stamp at a node
    %
    % INPUT
    % k = index, uint32 scalar
    %
    % OUTPUT
    % time = time stamp, Time scalar
    %
    % NOTES
    % Time stamps must not decrease with increasing indices
    % Throws an exception if data at the node is invalid
    % Throws an exception if input is of the wrong size
    time=getTime(this,k);
  end
  
end
