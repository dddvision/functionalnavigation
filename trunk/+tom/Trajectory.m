classdef Trajectory < handle
  
  methods (Abstract=true)
    interval=domain(this);
    pose=evaluate(this,t);
    tangentPose=tangent(this,t);
  end
  
end
