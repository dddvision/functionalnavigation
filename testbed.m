% This is the testbed script for components of the Trajectory Optimization 
%   Manager for Multiple Algorithms and Sensors (TOMMAS).
help(mfilename);

tommas;

testbedPath=fullfile(fileparts(mfilename('fullpath')),'testbed');
if(isempty(findstr(testbedPath,path)))
  addpath(testbedPath);
  fprintf('\npath added: %s',testbedPath);
end

config=TestbedConfig;

fprintf('\nname =');
assert(isa(config.name,'char'));
fprintf(' ''%s''',config.name);

fprintf('\ninitialTime =');
assert(isa(config.initialTime,'WorldTime')); 
fprintf(' %f',double(config.initialTime));

fprintf('\nuri =');
assert(isa(config.uri,'char'));
fprintf(' ''%s''',config.uri);

fprintf('\ndynamicModelName =');
assert(isa(config.dynamicModelName,'char'));
fprintf(' ''%s''',config.dynamicModelName);

fprintf('\nmeasureName =');
assert(isa(config.measureName,'char'));
fprintf(' ''%s''',config.measureName);

fprintf('\n\nDynamicModel.isConnected = ')
if(DynamicModel.isConnected(config.name))
  fprintf('yes');
else
  fprintf('no');
end
fprintf('\nMeasure.isConnected = ')
if(Measure.isConnected(config.name))
  fprintf('yes');
else
  fprintf('no');
end
fprintf('\nOptimizer.isConnected = ')
if(Optimizer.isConnected(config.name))
  fprintf('yes');
else
  fprintf('no');
end
fprintf('\nDataContainer.isConnected = ')
if(DataContainer.isConnected(config.name))
  fprintf('yes');
else
  fprintf('no');
end

if(DynamicModel.isConnected(config.name))
  DynamicModelTest(config.name,config.initialTime,config.uri);
end
if(Measure.isConnected(config.name))
  MeasureTest(config.name,config.uri);
end
if(Optimizer.isConnected(config.name))
  dynamicModel=DynamicModel.factory(config.dynamicModelName,config.initialTime,config.uri);
  measure{1}=Measure.factory(config.measureName,config.uri);
  OptimizerTest(config.name,dynamicModel,measure);
end
if(DataContainer.isConnected(config.name))
  DataContainerTest(config.name);
end

fprintf('\n\nDone');
