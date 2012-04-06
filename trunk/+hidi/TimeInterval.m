classdef TimeInterval
  
  properties (SetAccess = public, GetAccess = public)
    first = hidi.WorldTime(0);
    second = hidi.WorldTime(0);
  end
  
  methods (Access = public, Static = true)
    function this = TimeInterval(A, B)
      if(nargin==1)
        assert(isa(A(1).first, 'hidi.WorldTime'));
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
        assert(isa(A, 'hidi.WorldTime'));
        assert(isa(B, 'hidi.WorldTime'));
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
  
  methods (Access = public)  
    function display(this)
      for n = 1:numel(this)
        fprintf('\n%s = [%f, %f]\n', inputname(1), double(this(n).first), double(this(n).second));
      end
    end
  end
  
end
