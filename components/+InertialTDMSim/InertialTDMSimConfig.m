classdef InertialTDMSimConfig < handle
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  
  properties (Constant = true, GetAccess = public)
    model = 'RandomWalkOnly'; % type of IMU model
    tau = 2.5; % time step
  end
  
end
