function config=frameworkconfig

mainpath=fileparts(which('main'));
config.componentspath=fullfile(mainpath,'components');
config.trajectory='trajectorystub';
config.sensor='sensorstub';  % TODO: support multiple sensors
config.optimizer='optimizerstub';
config.iterations=1;

end
