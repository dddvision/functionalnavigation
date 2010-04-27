% This class represents a Pose and its time derivatives
%
% NOTES
% The initial undefined tangent pose is represented by NaN values for all parameters
classdef TangentPose < Pose
  properties
    r=nan(3,1); % time derivative of body position, double 3-by-1
    s=nan(4,1); % time derivative of body orientation, double 4-by-1 
  end
end
