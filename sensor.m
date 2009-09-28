classdef sensor
  
  methods (Access=protected)
    function this=sensor
    end
  end
  
  methods (Access=public,Abstract=false)
    % Return the first and last node indices
    %
    % OUTPUT
    % a = integer index of first node, double scalar
    % b = integer index of last node, double scalar
    %
    % NOTES
    % Returns a=NaN, b=NaN if no data is available
    % TODO: use matlab exceptions?
    [a,b]=domain(this);
    
    % Get time stamp associated with a node
    %
    % INPUT
    % k = integer index, double scalar
    %
    % OUTPUT
    % time = time stamp, double scalar
    %
    % NOTES
    % Time stamps must not decrease with increasing indices
    time=getTime(this,k);
  end
  
end
