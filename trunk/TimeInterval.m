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
        if(N==1)
          this.first=WorldTime(A.first);
          this.second=WorldTime(A.second);
        else
          this=repmat(this,[1,N]);
          for n=1:N
            this(n).first=WorldTime(A(n).first);
            this(n).second=WorldTime(A(n).second);
          end
        end
      elseif(nargin==2)
        N=numel(A);
        if(N==1)
          this.first=WorldTime(A);
          this.second=WorldTime(B);
        else
          this=repmat(this,[1,N]);
          for n=1:N
            this(n).first=WorldTime(A(n));
            this(n).second=WorldTime(B(n));
          end
        end
      end
    end
  end
end
