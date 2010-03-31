% This is an example application of the Trajectory Optimization Manager for 
%   Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer
%   and a graphical display, and then alternately optimizes and displays 
%   trajectories in an infinite loop. See demoConfig for options.
help(mfilename);

% close figures and clear the workspace
close('all');
clear('classes');
drawnow;

% check MATLAB version
try
  matlabVersion=version('-release');
catch err
  error('%s. Implement MATLAB Solution ID 1-5JUPSQ and restart MATLAB.',err.message);
end
if(str2double(matlabVersion(1:4))<2008)
  error('requires MATLAB version 2008a or greater');
end

% set the warning state
warning('on','all');
warning('off','MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

% add component repository to the path
componentPath=fullfile(fileparts(mfilename('fullpath')),'components');
addpath(componentPath);
fprintf('\npath added: %s',componentPath);

% reset the random stream state
reset(RandStream.getDefaultStream);

% get demo configuration
config=DemoConfig;

% instantiate a trajectory optimization manager
tom=Optimizer.factory(config.optimizerName,config.dynamicModelName,config.measureNames,config.dataUri);

% create an instance of the GUI
gui=DemoDisplay(config.dataUri);

% optimize forever
index=0;
while(true)
  % get the latest trajectory and cost estimates
  [x,cost]=getResults(tom);

  % update graphical display
  put(gui,x,cost,index);

  % take an optimization step
  step(tom);
  
  % increment the index
  index=index+1;
end
