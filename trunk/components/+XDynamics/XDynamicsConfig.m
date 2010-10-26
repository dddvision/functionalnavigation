classdef XDynamicsConfig < handle
  properties (Constant = true, GetAccess = public)
    % dynamic model parameters
    positionOffset = -1.2; % (-1.2) simulated offset in first position coordinate
    positionRateOffset = 0.2; % (0.2) simulated offset in first position rate coordinate
    positionDeviation = 2; % (2) standard deviation of initial position distribution
    positionRateDeviation = 0.1; % (1) standard deviation of initial position rate distribution
  end
end
