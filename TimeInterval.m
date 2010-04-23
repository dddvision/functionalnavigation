% This class represents an interval of time by its upper and lower bounds
classdef TimeInterval
  properties (SetAccess=public,GetAccess=public)
    first=WorldTime(-inf); % time lower bound, Time scalar
    second=WorldTime(inf); % time upper bound, Time scalar
  end
  methods (Access=public)
    function this=TimeInterval(first,second)
      if(nargin==2)
        this.first=WorldTime(first);
        this.second=WorldTime(second);
      end
    end
  end
end
