classdef TestbedConfig < handle
  properties (Constant=true,GetAccess=public)
    frameworkClass='DynamicModel'; % name of the abstract framework class to test
    pkg='BoundedMarkov'; % name of the specific component to test
    initialTime=WorldTime(0); % finite lower bound of trajectory time domain
    uri='matlab:MiddleburyData'; % data resource identifier
  end
end
