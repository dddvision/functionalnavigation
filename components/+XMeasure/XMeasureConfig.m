classdef XMeasureConfig < handle
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  properties (Constant = true, GetAccess = public)
    dt = 0.01; % (0.01) fixed time step
    deviation = 0.01; % (0.01) standard deviation of measurement distribution
  end
end
