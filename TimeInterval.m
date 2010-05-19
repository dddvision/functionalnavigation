% This class represents an interval of time by its upper and lower bounds
classdef TimeInterval
  properties (SetAccess=public,GetAccess=public)
    first % time lower bound, WorldTime scalar
    second % time upper bound, WorldTime scalar
  end
  methods (Access=public)
    function this=TimeInterval(A,B)
      if(nargin==1)
        N=numel(A);
        this=repmat(this,[1,N]);
        for n=1:N
          this(n).first=A(n).first;
          this(n).second=A(n).second;
        end
      elseif(nargin==2)
        N=numel(A);
        this=repmat(this,[1,N]);
        for n=1:N
          this(n).first=WorldTime(A(n));
          this(n).second=WorldTime(B(n));
        end
      end
    end
  end
end
