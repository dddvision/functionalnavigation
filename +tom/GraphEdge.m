classdef GraphEdge
  
  properties (SetAccess = public, GetAccess = public)
    first = uint32(0);
    second = uint32(0);
  end
  
  methods (Access = public, Static = true)
    function this = GraphEdge(A, B)
      if(nargin==1)
        assert(isa(A(1).first, 'uint32'));
        N = numel(A);
        if(N==1)
          this.first = A.first;
          this.second = A.second;
        else
          this(1, N) = this;
          for n = 1:N
            this(n).first = A(n).first;
            this(n).second = A(n).second;
          end
        end
      elseif(nargin==2)
        assert(isa(A, 'uint32'));
        assert(isa(B, 'uint32'));
        N = numel(A);
        if(N==1)
          this.first = A;
          this.second = B;
        else
          this(1, N) = this;
          for n = 1:N
            this(n).first = A(n);
            this(n).second = B(n);
          end
        end
      end
    end
  end
    
  methods (Access = public, Static = false)
    function display(this)
      fprintf('\n%s = ',inputname(1));
      for n = 1:numel(this)
        fprintf('[%d, %d] ', this(n).first, this(n).second);
      end
    end
  end
  
end
