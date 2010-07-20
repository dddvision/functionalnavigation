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
      fprintf('\n%s.p = [%f;%f;%f]',name,this.p(1),this.p(2),this.p(3));
      fprintf('\n%s.q = [%f;%f;%f;%f]',name,this.q(1),this.q(2),this.q(3),this.q(4));
      fprintf('\n%s.r = [%f;%f;%f]',name,this.r(1),this.r(2),this.r(3));
      fprintf('\n%s.s = [%f;%f;%f;%f]\n',name,this.s(1),this.s(2),this.s(3),this.s(4));      
    end
  end
end
