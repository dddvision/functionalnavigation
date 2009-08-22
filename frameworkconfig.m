function config=frameworkconfig

% TODO: support configuration of multiple sensors
mainpath=fileparts(which('main'));
config.trajectoryComponentPath=fullfile(mainpath,'trajectories');
config.sensorComponentPath=fullfile(mainpath,'sensors');
config.optimizerComponentPath=fullfile(mainpath,'optimizers');

config.trajectory='trajectorystub'; % try 'linewobble1','pendulum1'
config.sensor='sensorstub'; % try 'cameraOpticalFlow1'
config.optimizer='optimizerstub'; % try 'matlabGA1'

config.popsize=10;

end
