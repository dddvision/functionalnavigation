% This class represents an interval of time by its upper and lower bounds
classdef TimeInterval
  properties (SetAccess=public,GetAccess=public)
    first=Time(-inf); % time lower bound, Time scalar
    second=Time(inf); % time upper bound, Time scalar
  end
  methods (Access=public)
    function this=TimeInterval(first,second)
      if(nargin==2)
        this.first=Time(first);
        this.second=Time(second);
      end
    end
  end
end
