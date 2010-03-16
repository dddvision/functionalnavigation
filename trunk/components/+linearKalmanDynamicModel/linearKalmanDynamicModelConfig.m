classdef linearKalmanDynamicModelConfig < handle
  properties (Constant=true)
    simulatedInitialError=-1.2; % simulated initial error in first position coordinate
    priorVariance=2; % variance of initial position distribution
  end
end
