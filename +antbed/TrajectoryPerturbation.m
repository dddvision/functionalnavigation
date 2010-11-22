classdef TrajectoryPerturbation < tom.Trajectory

  properties (GetAccess = private, SetAccess = private)
      basePose
      deltaPose
      domainInterval
  end
    
  methods (Access = public, Static = true)
    % base trajectory and rotation (ie ground truth) passed as a tom.pose
    function this = TrajectoryPerturbation(pose,interval)
        this.basePose = pose;
        this.domainInterval = interval;
    end
  end
    
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = this.domainInterval;
    end
    function setPerturbation(this, offsetPose)
      this.deltaPose = offsetPose;
    end
    
    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        %TODO: Add interpolation for non-diecrete time values
        for k = 1:N
          pose(k).p = this.basePose.p + this.deltaPose.p;
          pose(k).q = Quat2Homo(this.deltaPose.q) * this.basePose.q;
        end
      end   
    end
  
    % the method returns 0 for the change in rate of rotation, this may be
    % implemented in the future
    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0)
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        tangentPose(1, N) = tom.TangentPose;
        for k = find(t>=this.initialTime)
          tangentPose(k).p = this.basePose.p + this.deltaPose.p;
          tangentPose(k).q = Quat2Homo(this.deltaPose.q) * this.basePose.q;
          tangentPose(k).r = [0; 0; 0];
          tangentPose(k).s = [0; 0; 0; 0];
        end
      end
    end
  end
end

function h = Quat2Homo(q)
  q1 = q(1);
  q2 = q(2);
  q3 = q(3);
  q4 = q(4);
  h = [[q1, -q2, -q3, -q4]
       [q2,  q1, -q4,  q3]
       [q3,  q4,  q1, -q2]
       [q4, -q3,  q2,  q1]];
end
