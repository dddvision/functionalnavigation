% This class represents the position and orientation of a body frame relative to a world frame
%
% NOTES
% Using SI units (meters, radians, seconds)
% Using an Earth Centered Earth Fixed (ECEF) convention for the world frame:
%   World Axis 1 goes through the equator at the prime meridian
%   World Axis 2 completes the frame using the right-hand-rule
%   World Axis 3 goes through the north pole
% Using a Forward-Right-Down (FRD) convention for the body frame:
%   Body Axis 1 points forward
%   Body Axis 2 points right
%   Body Axis 3 points down relative to the body (not gravity)
% The initial undefined pose is represented by NaN values for all parameters
classdef Pose
  properties (GetAccess=public,SetAccess=public)
    p=nan(3,1); % position of the body frame, double 3-by-1
    q=nan(4,1); % orientation of the body frame as a quaternion in scalar-first format, double 4-by-1
  end
  methods (Access=public)
    function this=Pose(S)
      if(nargin)
        N=numel(S);
        if(N==1)
          this.p=S.p;
          this.q=S.q;
        else
          this(1,N)=this;
          for n=1:N
            this(n).p=S(n).p;
            this(n).q=S(n).q;
          end
        end
      end
    end
    function display(this)
      name=inputname(1);
      fprintf('\n%s.p = [%f;%f;%f]',name,this.p(1),this.p(2),this.p(3));
      fprintf('\n%s.q = [%f;%f;%f;%f]\n',name,this.q(1),this.q(2),this.q(3),this.q(4));      
    end
  end
end
