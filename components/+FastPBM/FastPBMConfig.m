classdef FastPBMConfig < handle
  properties (Constant=true,GetAccess=public)
    maxFeatures = 300; % (300) maximum integer number of features per frame to find
    maxFrames = 10; % (10) maximum integer number of frames to track a feature
    maxSearch = 0.05; % (0.05) approximate maximum angle to search for a feature in radianss
    displayFeatures = true; % (false) show tracked features
  end
end
