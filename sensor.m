classdef sensor
  
  methods (Access=protected)
    function this=sensor
    end
  end
  
  methods (Access=public,Abstract=false)
    % Return first and last valid indices
    %
    % OUTPUT
    % a = first valid node index, uint32 scalar
    % b = last valid node index, uint32 scalar
    %
    % NOTES
    % Returns empty when no nodes are available
    % TODO: use exceptions for error handling
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
