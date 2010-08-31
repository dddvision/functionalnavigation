% This is the testbed script for components of the Trajectory Optimization 
%   Manager for Multiple Algorithms and Sensors (TOMMAS).
help(mfilename);

% check MATLAB version
try
  matlabVersion=version('-release');
catch err
  error('%s. Implement MATLAB Solution ID 1-5JUPSQ and restart MATLAB',err.message);
end
if(str2double(matlabVersion(1:4))<2009)
  error('\nTOMMAS requires MATLAB version 2009a or greater');
end

% close figures and clear everything except breakpoints
close('all');
breakpoints=dbstatus('-completenames');
save('breakpoints','breakpoints');
clear('classes');
load('breakpoints');
dbstop(breakpoints);

% set the warning state
warning('on','all');
warning('off','MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

% add component repository to the path
componentPath=fullfile(fileparts(mfilename('fullpath')),'components');
if(isempty(findstr(componentPath,path)))
  addpath(componentPath);
  fprintf('\npath added: %s',componentPath);
end

% add testbed folder to the path
testbedPath=fullfile(fileparts(mfilename('fullpath')),'testbed');
if(isempty(findstr(testbedPath,path)))
  addpath(testbedPath);
  fprintf('\npath added: %s',testbedPath);
end
  
% initialize the default pseudorandom number generator
reset(RandStream.getDefaultStream);

config=TestbedConfig;

fprintf('\nname =');
assert(isa(config.name,'char'));
fprintf(' ''%s''',config.name);

fprintf('\ninitialTime =');
assert(isa(config.initialTime,'tom.WorldTime')); 
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

fprintf('\n\ntom.DynamicModel.isConnected = ')
if(tom.DynamicModel.isConnected(config.name))
  fprintf('yes');
else
  fprintf('no');
end
fprintf('\ntom.Measure.isConnected = ')
if(tom.Measure.isConnected(config.name))
  fprintf('yes');
else
  fprintf('no');
end
fprintf('\ntom.Optimizer.isConnected = ')
if(tom.Optimizer.isConnected(config.name))
  fprintf('yes');
else
  fprintf('no');
end
fprintf('\ntom.DataContainer.isConnected = ')
if(tom.DataContainer.isConnected(config.name))
  fprintf('yes');
else
  fprintf('no');
end

if(tom.DynamicModel.isConnected(config.name))
  DynamicModelTest(config.name,config.initialTime,config.uri);
end
if(tom.Measure.isConnected(config.name))
  MeasureTest(config.name,config.uri);
end
if(tom.Optimizer.isConnected(config.name))
  dynamicModel=tom.DynamicModel.factory(config.dynamicModelName,config.initialTime,config.uri);
  measure{1}=tom.Measure.factory(config.measureName,config.uri);
  OptimizerTest(config.name,dynamicModel,measure);
end
if(tom.DataContainer.isConnected(config.name))
  DataContainerTest(config.name);
end

fprintf('\n\nDone');
