function config=frameworkconfig

% TODO: support configuration of multiple sensors
mainpath=fileparts(which('main'));
config.componentspath=fullfile(mainpath,'components');
config.trajectory='trajectorystub'; % try 'linewobble1','pendulum1'
config.sensor='sensorstub'; % try 'cameraOpticalFlow1'
config.optimizer='optimizerstub'; % NO OPTIMIZATION METHODS IMPLEMENTED YET
config.iterations=1;

end
