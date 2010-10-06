classdef OpticalFlowOpenCVConfig < handle
  properties (Constant=true,GetAccess=protected)
    displayFlow = true; % (true) display flow results
    isDense = false; % (false) compute flow over all pixels
    windowSize = 9; % (9) search window at each level
    levels = 5; % (5) number of pyramid levels to use
    verbose = false; % (false) display warnings and other diagnostic information
    maxCost = 20; % (20) maximum cost for a single graph edge
  end
end
