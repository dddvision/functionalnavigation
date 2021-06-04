classdef TangentPose < tom.Pose
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  properties (SetAccess = public, GetAccess = public)
    r = nan(3, 1);
    s = nan(3, 1);
  end
  
  methods (Access = public)
    function this = TangentPose(S)
      if(nargin)
        N = numel(S);
        this(1, N) = this;
        for n = 1:N
          this(n).p = S(n).p;
          this(n).q = S(n).q;
          this(n).r = S(n).r;
          this(n).s = S(n).s;
        end
      end
    end
    
    function display(this)
      name = inputname(1);
      for n = 1:numel(this)
        fprintf('\n%s.p = [%+9.6f; %+9.6f; %+9.6f]', name, this(n).p(1), this(n).p(2), this(n).p(3));
        fprintf('\n%s.q = [%+9.6f; %+9.6f; %+9.6f; %+9.6f]', name, this(n).q(1), this(n).q(2), this(n).q(3), ...
          this(n).q(4));
        fprintf('\n%s.r = [%+9.6f; %+9.6f; %+9.6f]', name, this(n).r(1), this(n).r(2), this(n).r(3));
        fprintf('\n%s.s = [%+9.6f; %+9.6f; %+9.6f]\n', name, this(n).s(1), this(n).s(2), this(n).s(3));
      end
    end
  end
end
