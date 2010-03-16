classdef linearKalmanOptimizerConfig < handle
  properties (Constant=true)
    referenceTime=0; % (0) initial time reference
    initialState=0.5; % (0.5) any value on the interval [0,1]
    plotDistributions=true; % (false) plots normal distributions when true
  end
end
