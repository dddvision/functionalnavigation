classdef BodyReference < MiddleburyData.MiddleburyDataConfig & tom.Trajectory

  properties (Constant = true,GetAccess = private)
    speed = 0.160; % Reference: http://vision.middlebury.edu/stereo/data/scenes2005/
  end

  properties (Access = private)
    interval
  end  

  methods (Access = public, Static = true)
    function this = BodyReference(initialTime)
      this.interval = tom.TimeInterval(initialTime, tom.WorldTime(initialTime+(double(this.numImages)-1)/this.fps));
    end
  end
    
  methods (Access = public, Static = false)
    function interval = domain(this)
      interval = this.interval;
    end

    function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, 0]);
      else
        pose(1, N) = tom.Pose;
        t = double(t);
        tmin = double(this.interval.first);
        good = (t>=tmin);
        dt = t-this.interval.first;
        for k = find(good)
          pose(k).p = [0; this.speed*dt(k); 0];
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
        tmin = double(this.interval.first);
        good = (t>=tmin);
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

end
