classdef XMeasureConfig < handle
  properties (Constant=true)
    dt=0.01; % (0.01) fixed time step
    deviation=0.01; % (0.01) deviation of measurement noise
    verbose=false; % (false) print messages to stdandard output
  end
end
