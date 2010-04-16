classdef BodyReference < MiddleburyData.MiddleburyDataConfig & Trajectory
  
  properties (SetAccess=private,GetAccess=private)
    bodyPath
    bodyPathDiff
    interval
  end  
  
  methods (Access=public)
    function this=BodyReference
      this.bodyPath='[0*t;t;0*t;1+0*t;0*t;0*t;0*t]';
      this.bodyPathDiff='[0*t;1+0*t;0*t;0*t;0*t;0*t;0*t]';
      this.interval=TimeInterval(0,(this.numImages-1)/this.fps);
    end

    function interval=domain(this)
      interval=this.interval;
    end

    function pose=evaluate(this,t)
      pose=repmat(Pose,[1,numel(t)]);
      posquat=double(eval(this.bodyPath)); % depends on t
      for k=find((t>=this.interval.first)&(t<=this.interval.second))
        pose(k).p=posquat(1:3,k);
        pose(k).q=posquat(4:7,k);
      end
    end
    
    function tangentPose=tangent(this,t)
      tangentPose=repmat(TangentPose,[1,numel(t)]);
      posquat=double(eval(this.bodyPath)); % depends on t
      posquatdot=double(eval(this.bodyPathDiff)); % depends on t
      for k=find((t>=this.interval.first)&(t<=this.interval.second))
        tangentPose(k).p=posquat(1:3,k);
        tangentPose(k).q=posquat(4:7,k);
        tangentPose(k).r=posquatdot(1:3,k);
        tangentPose(k).s=posquatdot(4:7,k);
      end
    end
  end
  
end
