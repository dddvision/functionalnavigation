classdef FastPBMConfig < handle
  properties (Constant=true,GetAccess=public)
    maxCost = 20; % (20) maximum cost for a single graph edge
    maxFeatures = 200; % (200) maximum integer number of features per frame to find
    maxSearch = 0.02; % (0.02) approximate maximum angle to search for a feature in radianss
    displayFeatures = true; % (false) show tracked features
  end
end
