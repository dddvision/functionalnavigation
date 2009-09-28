classdef sensor
  
  methods (Access=protected)
    function this=sensor
    end
  end
  
  methods (Access=public,Abstract=false)
    % Return the first and last node indices
    %
    % OUTPUT
    % a = integer index of first node, uint32 scalar
    % b = integer index of last node, uint32 scalar
    %
    % NOTES
    % Returns empty when no nodes are available
    % TODO: use exceptions for error handling
    [a,b]=domain(this);
    
    % Get time stamp associated with a node
    %
    % INPUT
    % k = integer index, uint32 scalar
    %
    % OUTPUT
    % time = time stamp, double scalar
    %
    % NOTES
    % Time stamps must not decrease with increasing indices
    time=getTime(this,k);
  end
  
end
