classdef matlabGA1Config < handle
  
    properties (Constant=true,GetAccess=protected)
      hasLicense = true; % (true) uses alternative non-GADS algorithm when set to false
      popSizeDefault = 20; % (20) default number of trajectories to test
      referenceTime = 0; % (0) start all trajectories at this time
      numBlocks = 4; % (4) number of parameter blocks supplied to the dynamic model
      dMax = uint32(10); % (uint32(10))optimize over no more than this many nodes, uint32
      crossoverFraction = 0.5; % (0.5) fraction of non-elite population to undergo crossover
      mutationRatio = 0.02; % (0.02) uniform mutation ratio
    end
  
end
