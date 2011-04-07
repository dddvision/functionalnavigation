classdef OpticalFlowOpenCVConfig < handle
  properties (Constant=true,GetAccess=protected)
    isDense = false; % (false) compute flow over all pixels
    windowSize = 9; % (9) search window at each level
    levels = 5; % (5) number of pyramid levels to use
    maxCost = 20; % (20) maximum cost for a single graph edge
    verbose = true; % (true) display warnings and other diagnostic information
    displayFlow = true; % (true) display flow results
    overwriteMEX = true; % (true) replace mex files if they already exist
  end
end
