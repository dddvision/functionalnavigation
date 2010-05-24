classdef BodyReference < MiddleburyData.MiddleburyDataConfig & Trajectory
  
  properties (SetAccess=private,GetAccess=private)
    interval
  end  
  
  methods (Access=public)
    function this=BodyReference
      this.interval=TimeInterval(WorldTime(0),WorldTime((this.numImages-1)/this.fps));
    end

    function interval=domain(this)
      interval=this.interval;
    end

    function pose=evaluate(this,t)
      pose(1,numel(t))=Pose;
      t=double(t);
      tmin=double(this.interval.first);
      tmax=double(this.interval.second);
      good=(t>=tmin)&(t<=tmax);
      for k=find(good)
        pose(k).p=[0;t(k);0];
        pose(k).q=[1;0;0;0];
      end
    end
    
    function tangentPose=tangent(this,t)
      tangentPose(1,numel(t))=TangentPose;
      t=double(t);
      tmin=double(this.interval.first);
      tmax=double(this.interval.second);
      good=(t>=tmin)&(t<=tmax);
      for k=find(good)
        tangentPose(k).p=[0;t(k);0];
        tangentPose(k).q=[1;0;0;0];
        tangentPose(k).r=[0;1;0];
        tangentPose(k).s=[0;0;0;0];
      end
    end
  end
  
end
