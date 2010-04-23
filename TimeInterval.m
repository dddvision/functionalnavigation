% This class represents an interval of time by its upper and lower bounds
classdef TimeInterval
  properties (SetAccess=public,GetAccess=public)
    first=GPSTime(-inf); % time lower bound, Time scalar
    second=GPSTime(inf); % time upper bound, Time scalar
  end
  methods (Access=public)
    function this=TimeInterval(first,second)
      if(nargin==2)
        this.first=GPSTime(first);
        this.second=GPSTime(second);
      end
    end
  end
end
