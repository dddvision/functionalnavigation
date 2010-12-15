classdef FastPBMConfig < handle
  properties (Constant = true, GetAccess = public)
    maxCost = 20; % (20) maximum cost for a single graph edge
    maxFeatures = 200; % (200) maximum integer number of features per frame to find
    maxSearch = 0.02; % (0.02) approximate maximum angle to search for a feature in radians
    displayFeatures = false; % (false) show tracked features
    calibrate = false; % (false) compute calibration
    trackerName = 'SparseTrackerKLT'; % ('SparseTrackerKLT') name of the tracker implementation to use
    angularDeviation = 0.005; % angular deviation of the tracker in radians
    % TODO: Manually change this calibration model.
    %       It should not be automatic, because human-validation is a part of modeling.
  end
end
