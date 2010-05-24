% This class represents an interval of time by its upper and lower bounds
classdef TimeInterval
  properties (SetAccess=public,GetAccess=public)
    first=WorldTime(0); % time lower bound, WorldTime scalar
    second=WorldTime(0); % time upper bound, WorldTime scalar
  end
  methods (Access=public)
    function this=TimeInterval(A,B)
      if(nargin==1)
        assert(isa(A(1).first,'WorldTime'));
        N=numel(A);
        if(N==1)
          this.first=A.first;
          this.second=A.second;
        else
          this(1,N)=this;
          for n=1:N
            this(n).first=A(n).first;
            this(n).second=A(n).second;
          end
        end
      elseif(nargin==2)
        assert(isa(A,'WorldTime'));
        assert(isa(B,'WorldTime'));
        N=numel(A);
        if(N==1)
          this.first=A;
          this.second=B;
        else
          this(1,N)=this;
          for n=1:N
            this(n).first=A(n);
            this(n).second=B(n);
          end
        end
      end
    end
  end
end
