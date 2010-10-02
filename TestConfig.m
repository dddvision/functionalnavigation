classdef TestConfig
  properties (Constant = true, Access = public)
    uri = 'matlab:MiddleburyData'; % default data resource identifier
    dynamicModel = 'Default'; % default dynamic model name
    measure = 'Default'; % default measure name
    initialTime = getCurrentTime(); % default initial time
  end
end
