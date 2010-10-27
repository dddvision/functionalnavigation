classdef TrajectoryDefault < tom.Trajectory
  
  properties (GetAccess = protected, SetAccess = protected)
    initialTime
  end
  
  methods (Access = public, Static = true)
    function this = TrajectoryDefault(initialTime)
      this.initialTime = initialTime;
    end
  end
  
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = tom.TimeInterval(this.initialTime, tom.WorldTime(Inf));
    end
  
    function pose = evaluate(this, t)
      pose.p = [0; 0; 0];
      pose.q = [1; 0; 0; 0];
      pose = tom.Pose(pose);
      pose = repmat(pose, [1, numel(t)]);
      for k = find(t<this.initialTime)
        pose(k) = tom.Pose;
      end
    end

    function tangentPose = tangent(this, t)
      tangentPose.p = [0; 0; 0];
      tangentPose.q = [1; 0; 0; 0];
      tangentPose.r = [0; 0; 0];
      tangentPose.s = [0; 0; 0; 0];
      tangentPose = tom.TangentPose(tangentPose);
      tangentPose = repmat(tangentPose, [1, numel(t)]);
      for k = find(t<this.initialTime)
        tangentPose(k) = tom.TangentPose;
      end
    end
  end
  
end
