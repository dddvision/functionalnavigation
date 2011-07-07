classdef TestConfig
  properties (Constant = true, GetAccess = public)
    uri = 'antbed:MiddleburyTemple'; % data resource identifier
    dynamicModelName = 'tom'; % dynamic model name
    measureNames = {'tom'}; % cell array of measure names
    initialTime = antbed.getCurrentTime(); % default initial time
    characterize = false; % characterize measures
  end
end
