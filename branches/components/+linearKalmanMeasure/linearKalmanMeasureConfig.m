classdef linearKalmanMeasureConfig < handle
  properties (Constant=true)
    dt=0.001; % ASSUMPTION: fixed known time step
    sigma=0.5; % ASSUMPTION: fixed known noise parameter
  end
end
