classdef linearKalmanDynamicModelConfig < handle
  properties (Constant=true)
    positionOffset=-1.2; % simulated offset in first position coordinate
    positionRateOffset=0.2; % simulated offset in first position rate coordinate
    positionDeviation=2; % standard deviation of initial position distribution
    positionRateDeviation=0.1; % standard deviation of initial position rate distribution
  end
end
