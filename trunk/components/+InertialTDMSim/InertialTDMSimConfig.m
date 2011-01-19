classdef InertialTDMSimConfig < handle
  
  properties (Constant = true, GetAccess = public)
    model = 'RandomWalkOnly'; % type of IMU model
    tau = 2.5; % time step
  end
  
end
