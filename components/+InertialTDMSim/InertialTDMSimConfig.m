classdef InertialTDMSimConfig < handle
% Copyright 2006 David D. Diel, MIT License
  
  properties (Constant = true, GetAccess = public)
    model = 'RandomWalkOnly'; % type of IMU model
    tau = 2.5; % time step
  end
  
end
