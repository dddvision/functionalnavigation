% This is an example application of the Trajectory Optimization Manager for 
%   Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer
%   and a graphical display, and then alternately optimizes and displays 
%   trajectories in an infinite loop. See DemoConfig for options.
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
  
% initialize the default pseudorandom number generator
reset(RandStream.getDefaultStream);

% get configuration
config=DemoConfig;

% initialize multiple measures
M=numel(config.measureNames);
measure=cell(M,1);
for m=1:M
  measure{m}=tom.Measure.factory(config.measureNames{m},config.uri);
end

% determine initial time based on first available data node
initialTime=tom.WorldTime(Inf);
for m=1:M
  measure{m}.refresh();
  if(measure{m}.hasData())
    initialTime=tom.WorldTime(min(initialTime,measure{m}.getTime(measure{m}.first())));
  end
end

% use default initial time when no data is available
if(isinf(initialTime))
  initialTime=config.defaultInitialTime;
end
  
% initialize multiple dynamic models
dynamicModel=tom.DynamicModel.factory(config.dynamicModelName,initialTime,config.uri);
for k=2:config.numTrajectories
  dynamicModel(k)=tom.DynamicModel.factory(config.dynamicModelName,initialTime,config.uri);
end

% instantiate an optimizer
optimizer=tom.Optimizer.factory(config.optimizerName,dynamicModel,measure);

% instantiate the graphical display
gui=DemoDisplay(config.uri);

% optimize for a number of steps
for index=uint32(0):config.numSteps
  % check number of results
  K=optimizer.numResults();
  
  % if there are any results
  if(K>uint32(0))
    % get all trajectory and cost estimates
    trajectory=optimizer.getTrajectory(uint32(0));
    cost=optimizer.getCost(uint32(0));
    for k=uint32(1):(K-uint32(1))
      trajectory(k,1)=optimizer.getTrajectory(k);
      cost(k,1)=optimizer.getCost(k);
    end
    
    % update graphical display
    gui.put(trajectory,cost,index);
  end
    
  % take an optimization step
  optimizer.step();
end
