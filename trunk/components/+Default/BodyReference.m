classdef BodyReference < tom.Trajectory
  
  properties (GetAccess = private, SetAccess = private)
    initialTime
  end
  
  methods (Access = public, Static = true)
    function this = BodyReference(initialTime)
      this.initialTime = initialTime;
    end
  end
  
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = tom.TimeInterval(this.initialTime, Inf);
    end
  
    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        pose(1, N) = tom.Pose;
        t = double(t);
        tmin = double(this.initialTime);
        good = (t>=tmin);
        dt = t-this.initialTime;
        for k = find(good)
          pose(k).p = [0; dt(k); 0];
          pose(k).q = [1; 0; 0; 0];
        end
      end
    end

    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0)
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        tangentPose(1, N) = tom.TangentPose;
        t = double(t);
        tmin = double(this.initialTime);
        good = (t>=tmin);
        dt = t-this.initialTime;
        for k = find(good)
          tangentPose(k).p = [0; dt(k); 0];
          tangentPose(k).q = [1; 0; 0; 0];
          tangentPose(k).r = [0; 1; 0];
          tangentPose(k).s = [0; 0; 0; 0];
        end
      end
    end
  end
  
end
