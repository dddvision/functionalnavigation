classdef MatlabGAConfig < handle
  properties (Constant=true,GetAccess=protected)
    hasLicense = true; % (true) uses alternative non-GADS algorithm when set to false
    popSize = 20; % (20) number of trajectories to test
    dMax = uint32(100); % (uint32(100))optimize over no more than this many nodes, uint32
    crossoverFraction = 0.5; % (0.5) fraction of non-elite population to undergo crossover
    mutationRatio = 0.02; % (0.02) uniform mutation ratio
  end
end
