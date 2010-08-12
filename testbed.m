% This is the testbed script for components of the Trajectory Optimization 
%   Manager for Multiple Algorithms and Sensors (TOMMAS).
help(mfilename);

% initialize tommas
tommas;

% add testbed repository to the path
testbedPath=fullfile(fileparts(mfilename('fullpath')),'testbed');
if(isempty(findstr(testbedPath,path)))
  addpath(testbedPath);
  fprintf('\npath added: %s',testbedPath);
end

% get configuration
config=TestbedConfig;

switch(config.frameworkClass)
  case 'DynamicModel'
    DynamicModelTest(config.pkg,config.initialTime,config.uri);
    break;
  case 'Measure'
    MeasureTest(config.pkg,config.uri);
    break;
  case 'Optimizer'
    fprintf('\nThere are no tests defined for the Optimizer class');
    break;
  otherwise
    fprintf('\n%s is not a TOMMAS framework class',class(config.frameworkClass));
end
