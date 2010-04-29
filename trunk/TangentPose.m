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
        this=repmat(this,[1,N]);
        for n=1:N
          this(n).p=S(n).p;
          this(n).q=S(n).q;
          this(n).r=S(n).r;
          this(n).s=S(n).s;
        end
      end
    end
  end
end
