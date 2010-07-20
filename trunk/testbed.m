% This is the testbed script for components of the Trajectory Optimization 
%   Manager for Multiple Algorithms and Sensors (TOMMAS).
help(mfilename);

% initialize tommas
tommas;

% get configuration
config=TestbedConfig;

switch(config.frameworkClass)
  case 'DynamicModel'
    DynamicModelTest(config.pkg,WorldTime(0),'uri');
    break;
  case 'Measure'
    fprintf('\nThere are no tests defined for the Measure class');
    break;
  case 'Optimizer'
    fprintf('\nThere are no tests defined for the Optimizer class');
    break;
  otherwise
    fprintf('\n%s is not a TOMMAS framework class',class(config.frameworkClass));
end
