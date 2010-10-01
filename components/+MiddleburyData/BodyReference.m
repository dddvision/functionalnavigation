classdef BodyReference < MiddleburyData.MiddleburyDataConfig & tom.Trajectory

  properties (Constant = true,GetAccess = private)
    speed = 0.160; % Reference: http://vision.middlebury.edu/stereo/data/scenes2005/
  end

  properties (Access = private)
    interval
  end  

  methods (Access = public, Static = true)
    function this = BodyReference(initialTime)
      this.interval = tom.TimeInterval(initialTime, tom.WorldTime(initialTime+(this.numImages-1)/this.fps));
    end
  end
    
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = this.interval;
    end

    function pose = evaluate(this, t)
      pose(1, numel(t)) = tom.Pose;
      t = double(t);
      tmin = double(this.interval.first);
      tmax = double(this.interval.second);
      good = (t>=tmin)&(t<=tmax);
      dt = t-this.interval.first;
      for k = find(good)
        pose(k).p = [0; this.speed*dt(k); 0];
        pose(k).q = [1; 0; 0; 0];
      end
    end

    function tangentPose = tangent(this, t)
      tangentPose(1, numel(t)) = tom.TangentPose;
      t = double(t);
      tmin = double(this.interval.first);
      tmax = double(this.interval.second);
      good = (t>=tmin)&(t<=tmax);
      dt = t-this.interval.first;
      for k = find(good)
        tangentPose(k).p = [0; this.speed*dt(k); 0];
        tangentPose(k).q = [1; 0; 0; 0];
        tangentPose(k).r = [0; this.speed; 0];
        tangentPose(k).s = [0; 0; 0; 0];
      end
    end
  end

end
