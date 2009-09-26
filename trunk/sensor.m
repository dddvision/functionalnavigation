classdef sensor
  methods (Access=protected)
    function this=sensor
    end
  end
  methods (Access=public,Abstract=false)
    % Return the first and last data indices
    %
    % OUTPUT
    % a = integer index of first data element, double scalar
    % b = integer index of last data element, double scalar
    %
    % NOTES
    % Returns a=NaN, b=NaN if no data is available
    % TODO: use matlab exceptions?
    [a,b]=domain(this);
    
    % Get time stamps associated with data index
    %
    % INPUT
    % k = integer index, double scalar
    %
    % OUTPUT
    % time = time stamp for each index, double scalar
    %
    % NOTES
    % Time stamps must not decrease with increasing indices
    time=gettime(this,k);
        
  end
end
