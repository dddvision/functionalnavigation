classdef linearKalmanMeasureConfig < handle
  properties (Constant=true)
    dt=0.1; % ASSUMPTION: fixed known time step
    sigma=1; % ASSUMPTION: fixed known noise parameter
  end
end
