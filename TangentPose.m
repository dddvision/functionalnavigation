% This class represents a Pose and its time derivatives
%
% NOTES
% The initial undefined tangent pose is represented by NaN values for all parameters
classdef TangentPose < Pose
  properties (SetAccess=public,GetAccess=public)
    r=nan(3,1); % time derivative of body position, double 3-by-1
    s=nan(4,1); % time derivative of body orientation, double 4-by-1 
  end
  methods (Access=public)
    function this=TangentPose(S)
      if(nargin)
        N=numel(S);
        this(1,N)=this;
        for n=1:N
          this(n).p=S(n).p;
          this(n).q=S(n).q;
          this(n).r=S(n).r;
          this(n).s=S(n).s;
        end
      end
    end
    function display(this)
      name=inputname(1);
      for n=1:numel(this)
        fprintf('\n%s.p = [%f;%f;%f]',name,this(n).p(1),this(n).p(2),this(n).p(3));
        fprintf('\n%s.q = [%f;%f;%f;%f]',name,this(n).q(1),this(n).q(2),this(n).q(3),this(n).q(4));
        fprintf('\n%s.r = [%f;%f;%f]',name,this(n).r(1),this(n).r(2),this(n).r(3));
        fprintf('\n%s.s = [%f;%f;%f;%f]\n',name,this(n).s(1),this(n).s(2),this(n).s(3),this(n).s(4));
      end
    end
  end
end
