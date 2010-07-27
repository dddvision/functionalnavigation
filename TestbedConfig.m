classdef TestbedConfig < handle
  properties (Constant=true,GetAccess=public)
    frameworkClass='DynamicModel'; % name of the abstract framework class to test
    pkg='XDynamics'; % name of the specific component to test
    initialTime=WorldTime(0);
    uri='matlab:MiddleburyData';
    alpha=10*eps; % semi-small number
  end
end
