classdef XMeasureConfig < handle
  properties (Constant = true, GetAccess = public)
    dt = 0.01; % (0.01) fixed time step
    deviation = 0.01; % (0.01) standard deviation of measurement distribution
  end
end
