function config=frameworkConfig

% TODO: support configuration of multiple measures
% TODO: measure/sensor compatibility checking
mainpath=fileparts(which('main'));
config.trajectoryComponentPath=fullfile(mainpath,'trajectories');
config.measureComponentPath=fullfile(mainpath,'measures');
config.optimizerComponentPath=fullfile(mainpath,'optimizers');

config.trajectory='trajectorystub'; % try 'trajectorystub' or 'lineWobble1'
config.measure='measurestub'; % try 'measurestub' or 'opticalFlow1'
config.optimizer='optimizerstub'; % try 'optimizerstub' or 'matlabGA1'

end
