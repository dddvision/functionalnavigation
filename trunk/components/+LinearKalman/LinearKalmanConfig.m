classdef LinearKalmanConfig < handle
  properties (Constant = true, GetAccess = public)
    % optimizer parameters
    popSize = 1; % (1) number of trajectories to optimize over
  end
end
