classdef Trajectory < handle  
  methods (Access = public, Abstract = true)
    interval = domain(this);
    pose = evaluate(this, t);
    tangentPose = tangent(this, t);
  end
end
