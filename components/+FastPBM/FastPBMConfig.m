classdef FastPBMConfig < handle
  properties (Constant = true, GetAccess = public)
    % parameters that affect the measure
    maxFeatures = 500; % (500) maximum integer number of features per frame to find
    maxSearch = 0.02; % (0.02) approximate maximum angle to search for a feature in radians
    trackerName = 'SparseTrackerKLT'; % ('SparseTrackerKLT') name of the tracker implementation to use
    
    %partitions = [0, 0.000439, 0.0028, pi];
    partitions = [0, 5.2528e-05, 1.3324e-04, 3.1558e-04, 1.1538e-03, pi];
    
    %densities = [0.6648, 0.2315, 0.1037];
    
    % parameters that do not affect the measure
    displayFeatures = false; % (false) show tracked features
    overwriteMEX = true; % (true) replace mex files if they already exist
  end
end
