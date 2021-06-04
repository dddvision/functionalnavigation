classdef Trajectory < handle  
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  methods (Access = public, Abstract = true)
    interval = domain(this);
    pose = evaluate(this, t);
    tangentPose = tangent(this, t);
  end
end
