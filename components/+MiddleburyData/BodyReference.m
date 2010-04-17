classdef BodyReference < MiddleburyData.MiddleburyDataConfig & Trajectory
  
  properties (SetAccess=private,GetAccess=private)
    interval
  end  
  
  methods (Access=public)
    function this=BodyReference
      this.interval=TimeInterval(0,(this.numImages-1)/this.fps);
    end

    function interval=domain(this)
      interval=this.interval;
    end

    function pose=evaluate(this,t)
      pose=repmat(Pose,[1,numel(t)]);
      good=find((t>=this.interval.first)&(t<=this.interval.second));
      t=double(t);
      for k=good
        pose(k).p=[0;t(k);0];
        pose(k).q=[1;0;0;0];
      end
    end
    
    function tangentPose=tangent(this,t)
      tangentPose=repmat(TangentPose,[1,numel(t)]);
      good=find((t>=this.interval.first)&(t<=this.interval.second));
      t=double(t);
      for k=good
        tangentPose(k).p=[0;t(k);0];
        tangentPose(k).q=[1;0;0;0];
        tangentPose(k).r=[0;1;0];
        tangentPose(k).s=[0;0;0;0];
      end
    end
  end
  
end
