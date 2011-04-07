classdef FastPBMConfig < handle
  properties (Constant = true, GetAccess = public)
    % parameters that affect the measure
    maxCost = 20; % (20) maximum cost for a single graph edge
    maxFeatures = 500; % (500) maximum integer number of features per frame to find
    maxSearch = 0.02; % (0.02) approximate maximum angle to search for a feature in radians
    trackerName = 'SparseTrackerKLT'; % ('SparseTrackerKLT') name of the tracker implementation to use
    angularDeviation = 0.003; % angular deviation of the tracker in radians

    % parameters that do not affect the measure
    displayFeatures = true; % (false) show tracked features
    overwriteMEX = true; % (true) replace mex files if they already exist
  end
end
