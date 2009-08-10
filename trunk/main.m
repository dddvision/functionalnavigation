fprintf('\n### framework initialization ###');
close all;
clear classes;
drawnow;
warning('on','all');
intwarning('off');
rand('seed',0);
randn('seed',0);

config=frameworkconfig;

addpath(config.trajectoryComponentPath);
fprintf('\npath added: %s',config.trajectoryComponentPath);
addpath(config.sensorComponentPath);
fprintf('\npath added: %s',config.sensorComponentPath);
addpath(config.optimizerComponentPath);
fprintf('\npath added: %s',config.optimizerComponentPath);

H=objective(config);
M=feval(config.optimizer);
[M,v,w]=init(M,H);
for n=1:config.iterations
  [M,H,v,w]=step(M,H,v,w);
end
