classdef FastPBMConfig < handle
  properties (Constant=true,GetAccess=public)
    maxFeatures = 30; % (30) maximum integer number of features per frame to find
    maxFrames = 10; % (10) maximum integer number of frames to track a feature
    maxSearch = 0.05; % (0.05) approximate maximum angle to search for a feature in radians
  end
end
