classdef DefaultTrajectory < tom.Trajectory
  
  properties (GetAccess = private, SetAccess = private)
    initialTime
    initialPose
    initialTangentPose
  end
  
  methods (Access = public, Static = true)
    function this = DefaultTrajectory(initialTime)
      tP.p = [0; 0; 0];
      tP.q = [1; 0; 0; 0];
      tP.r = [0; 0; 0];
      tP.s = [0; 0; 0; 0];
      this.initialTime = initialTime;
      this.initialPose = tom.Pose(tP);
      this.initialTangentPose = tom.TangentPose(tP);
    end
  end
  
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = tom.TimeInterval(this.initialTime, tom.WorldTime(Inf));
    end
  
    function pose = evaluate(this, t)
      pose = repmat(this.initialPose, [1, numel(t)]);
      for k = find(t<this.initialTime)
        pose(k) = tom.Pose;
      end
    end

    function tangentPose = tangent(this, t)
      tangentPose = repmat(this.initialTangentPose, [1, numel(t)]);
      for k = find(t<this.initialTime)
        tangentPose(k) = tom.TangentPose;
      end
    end
  end
  
end
