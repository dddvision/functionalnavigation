classdef TestbedConfig < handle
  properties (Constant=true,GetAccess=public)
    frameworkClass='DynamicModel'; % name of the abstract framework class to test
    pkg='BrownianPlanar'; % name of the specific component to test  
  end
end
