% This is an example application of the Trajectory Optimization Manager for 
%   Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer
%   and a graphical display, and then alternately optimizes and displays 
%   trajectories in an infinite loop. See DemoConfig for options.
help(mfilename);

% check MATLAB version
try
  matlabVersion = version('-release');
catch err
  error('%s. Implement MATLAB Solution ID 1-5JUPSQ and restart MATLAB', err.message);
end
if(str2double(matlabVersion(1:4))<2009)
  error('\nTOMMAS requires MATLAB version 2009a or greater');
end

% close figures and clear everything except breakpoints
close('all');
breakpoints = dbstatus('-completenames');
save('temp.mat', 'breakpoints');
clear('classes');
load('temp.mat');
dbstop(breakpoints);

% add component repository to the path
componentPath = fullfile(fileparts(mfilename('fullpath')), 'components');
if(isempty(findstr(componentPath, path)))
  addpath(componentPath);
  fprintf('\naddpath = %s', componentPath);
end

% set the warning state
warning('on', 'all');
warning('off', 'MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"
  
% initialize the default pseudorandom number generator
RandStream.getDefaultStream.reset();

% get configuration
config = DemoConfig;

% get system time
initialTime = getCurrentTime();

% instantiate the graphical display
gui = DemoDisplay(initialTime, config.uri);

% instantiate an optimizer
name = config.optimizerName;
fprintf('\n\nInitializing Optimizer: %s', name);
if(tom.Optimizer.isConnected(name))
  fprintf('\n%s', tom.Optimizer.description(name));
  optimizer = tom.Optimizer.create(name);
else
  error('TOMMAS component is not recognized. Ensure that it is present in the MATLAB path.');
end

% initialize multiple measures
M = numel(config.measureNames);
measure = cell(M, 1);
for m = 1:M
  name = config.measureNames{m};
  fprintf('\n\nInitializing Measure: %s', name);
  if(tom.Measure.isConnected(name))
    fprintf('\n%s', tom.Measure.description(name));
    measure{m} = tom.Measure.create(name, initialTime, config.uri);
  else
    error('TOMMAS component is not recognized. Ensure that it is present in the MATLAB path.');
  end
end

% initialize multiple dynamic models
name = config.dynamicModelName;
fprintf('\n\nInitializing DynamicModel: %s', name);
if(tom.DynamicModel.isConnected(name))
  fprintf('\n%s', tom.DynamicModel.description(name));
  dynamicModel = tom.DynamicModel.create(name, initialTime, config.uri);
  for k = 2:optimizer.numInitialConditions()
    dynamicModel(k) = tom.DynamicModel.create(name, initialTime, config.uri);
  end
else
  error('TOMMAS component is not recognized. Ensure that it is present in the MATLAB path.');
end

% define the problem
optimizer.defineProblem(dynamicModel, measure, true);

% optimize for a number of steps
for index = uint32(0):config.numSteps
  % check number of solutions
  K = optimizer.numSolutions();
  
  % if there are any solutions
  if(K>uint32(0))
    % get all trajectory and cost estimates
    trajectory = optimizer.getSolution(uint32(0));
    cost = optimizer.getCost(uint32(0));
    for k = uint32(2):K
      trajectory(k, 1) = optimizer.getSolution(k-uint32(1));
      cost(k, 1) = optimizer.getCost(k-uint32(1));
    end
    
    % update graphical display
    gui.put(trajectory, cost, index);
  end
    
  % refresh the problem
  optimizer.refreshProblem();
  
  % take an optimization step
  optimizer.step();
end
