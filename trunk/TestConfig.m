classdef TestConfig
  properties (Constant = true, GetAccess = public)
    uri = 'antbed:MiddleburyData'; % default data resource identifier
    dynamicModel = 'tom'; % default dynamic model name
    measure = {'tom'}; % default measure names
    initialTime = getCurrentTime(); % default initial time
  end
end
