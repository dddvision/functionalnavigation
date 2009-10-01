% NOTES
% TODO: define exceptions for invalid indices and other errors
classdef sensor
  
  methods (Abstract=true)
    % Return first and last indices from a valid consecutive list
    %
    % OUTPUT
    % ka = first valid node index, uint32 scalar
    % kb = last valid node index, uint32 scalar
    %
    % NOTES
    % Returns empty when no nodes are available
    [ka,kb]=domain(this);
    
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

    % Lock the data buffer so that indices do not change during subsequent calls
    lock(this);
    
    % Unlock the data buffer for write access from simulated or real sensor
    unlock(this);
  end
  
end
