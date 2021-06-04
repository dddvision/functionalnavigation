classdef TrajectorySimConfig < handle
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  properties (Constant = true, GetAccess = public)
    % The pose file is comma separated in the following format
    % dt, p1, p2, p3, q1, q2, q3, q4, r1, r2, r3, s1, s2, s3, s4
    tangentPoseFileName = 'tangentPoseFile.dat';
    timeScale = 10.0;
    translationScale = 1000.0;
  end
end
