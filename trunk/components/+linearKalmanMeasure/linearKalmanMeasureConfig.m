classdef linearKalmanMeasureConfig < handle
  properties (Constant=true)
    dt=0.001; % fixed time step
    deviation=0.1; % deviation of measurement noise
  end
end
