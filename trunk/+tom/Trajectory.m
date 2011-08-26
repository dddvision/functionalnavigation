classdef Trajectory < handle
   
  methods (Abstract = true, Access = public, Static = false)
    interval = domain(this);
    pose = evaluate(this, t);
    tangentPose = tangent(this, t);
  end
  
end
