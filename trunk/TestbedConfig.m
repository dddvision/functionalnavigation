classdef TestbedConfig < handle
  
  properties (Constant=true,GetAccess=public)
    name='BrownianPlanar'; % name of the component to test
    initialTime=WorldTime(0); % default finite lower bound of trajectory time domain
    uri='matlab:MiddleburyData'; % default data resource identifier
    dynamicModelName='XDynamics'; % default dynamic model name
    measureName='XMeasure'; % default measure name
  end
  
end
