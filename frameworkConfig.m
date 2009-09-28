function config=frameworkConfig

mainpath=fileparts(which('main'));
config.componentPath=fullfile(mainpath,'components');

% TODO: support configuration of multiple sensors/measures
% TODO: measure/sensor compatibility checking
config.sensor='cameraSim1';
config.trajectory='trajectorystub'; % try 'trajectorystub' or 'lineWobble1'
config.measure='measurestub'; % try 'measurestub' or 'opticalFlow1'
config.optimizer='optimizerstub'; % try 'optimizerstub' or 'matlabGA1'

end
