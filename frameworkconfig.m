function config=frameworkconfig

% TODO: support configuration of multiple sensors
mainpath=fileparts(which('main'));
config.trajectoryComponentPath=fullfile(mainpath,'trajectories');
config.sensorComponentPath=fullfile(mainpath,'sensors');
config.optimizerComponentPath=fullfile(mainpath,'optimizers');

config.trajectory='linewobble1'; % try 'trajectorystub' or 'linewobble1'
config.sensor='cameraOpticalFlow1'; % try 'sensorstub' or 'cameraOpticalFlow1'
config.optimizer='matlabGA1'; % try 'optimizerstub' or 'matlabGA1'

end
