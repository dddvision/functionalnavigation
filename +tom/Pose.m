classdef Pose
  
  properties (GetAccess = public, SetAccess = public)
    p = nan(3, 1);
    q = nan(4, 1);
  end
  
  methods (Access = public, Static = true)
    function this = Pose(S)
      if(nargin)
        N = numel(S);
        if(N==1)
          this.p = S.p;
          this.q = S.q;
        else
          this(1, N) = this;
          for n = 1:N
            this(n).p = S(n).p;
            this(n).q = S(n).q;
          end
        end
      end
    end
  end
    
  methods (Access = public)
    function display(this)
      name = inputname(1);
      for n = 1:numel(this)
        fprintf('\n%s.p = [%f; %f; %f]', name, this(n).p(1), this(n).p(2), this(n).p(3));
        fprintf('\n%s.q = [%f; %f; %f; %f]\n', name, this(n).q(1), this(n).q(2), this(n).q(3), this(n).q(4));
      end
    end
  end
  
end
