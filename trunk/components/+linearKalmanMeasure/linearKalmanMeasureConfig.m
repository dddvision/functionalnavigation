classdef linearKalmanMeasureConfig < handle
  properties (Constant=true)
    dt=0.01; % fixed time step
    deviation=0.01; % deviation of measurement noise
  end
end
