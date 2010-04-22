% This is an example application of the Trajectory Optimization Manager for 
%   Multiple Algorithms and Sensors (TOMMAS). It instantiates an optimizer
%   and a graphical display, and then alternately optimizes and displays 
%   trajectories in an infinite loop. See DemoConfig for options.
help(mfilename);

% check MATLAB version
try
  matlabVersion=version('-release');
catch err
  error('%s. Implement MATLAB Solution ID 1-5JUPSQ and restart MATLAB.',err.message);
end
if(str2double(matlabVersion(1:4))<2008)
  error('TOMMAS requires MATLAB version 2008a or greater');
end

% close figures and clear the workspace
close('all');
clear('classes');

% set the warning state
warning('on','all');
warning('off','MATLAB:intMathOverflow'); % see performance remark in "doc intwarning"

% add component repository to the path
componentPath=fullfile(fileparts(mfilename('fullpath')),'components');
addpath(componentPath);
fprintf('\npath added: %s',componentPath);

% initialize the default pseudorandom number generator
reset(RandStream.getDefaultStream);

% get configuration
config=DemoConfig;

% instantiate an optimizer
optimizer=Optimizer.factory(config.optimizerName,config.dynamicModelName,config.measureNames,config.uri);

% instantiate the graphical display
gui=DemoDisplay(config.uri);

% optimize forever
index=0;
while(true)
  % get the latest trajectory and cost estimates
  [trajectory,cost]=getResults(optimizer);

  % update graphical display
  put(gui,trajectory,cost,index);

  % take an optimization step
  step(optimizer);
  
  % increment index
  index=index+1;
end
