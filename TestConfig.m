classdef TestConfig
  properties (Constant = true, GetAccess = public)
    uri = 'matlab:MiddleburyData'; % default data resource identifier
    dynamicModel = 'tom.Default'; % default dynamic model name
    measure = 'tom.Default'; % default measure name
    initialTime = getCurrentTime(); % default initial time
  end
end
