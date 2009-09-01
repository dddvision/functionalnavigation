function config=frameworkConfig

% TODO: support configuration of multiple sensors
mainpath=fileparts(which('main'));
config.trajectoryComponentPath=fullfile(mainpath,'trajectories');
config.sensorComponentPath=fullfile(mainpath,'sensors');
config.optimizerComponentPath=fullfile(mainpath,'optimizers');

config.trajectory='trajectorystub'; % try 'trajectorystub' or 'linewobble1'
config.sensor='sensorstub'; % try 'sensorstub' or 'cameraOpticalFlow1'
config.optimizer='optimizerstub'; % try 'optimizerstub' or 'matlabGA1'

end
