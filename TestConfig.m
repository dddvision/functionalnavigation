classdef TestConfig
  properties (Constant = true, GetAccess = public)
    uri = 'antbed:MiddleburyTemple'; % data resource identifier
    dynamicModel = 'tom'; % dynamic model name
    measure = {'tom'}; % cell array of measure names
    initialTime = antbed.getCurrentTime(); % default initial time
  end
end
