classdef FastPBMConfig < handle
  properties (Constant = true, GetAccess = public)
    % parameters that affect the measure
    maxFeatures = 500; % (500) maximum integer number of features per frame to find
    maxSearch = 0.02; % (0.02) approximate maximum angle to search for a feature in radians
    trackerName = 'SparseTrackerSURF'; % ('SparseTrackerKLT') name of the tracker implementation to use    
    deviation = 0.16; % unitless tracker error parameter
    
    % parameters that do not affect the measure
    displayFeatures = true; % (false) show tracked features
    overwriteMEX = true; % (true) replace mex files if they already exist
  end
end
