% This script is an example application of the Trajectory Optimization 
%   Manager for Multiple Algorithms and Sensors (TOMMAS). It instantiates a
%   tommas object and a graphical display, and then alternately optimizes 
%   and displays trajectories in an infinite loop. See tommasConfig for 
%   configuration options.
help('main');

% clear the workspace and the screen
close('all');
clear('classes');
drawnow;

% check MATLAB version before instantiating any objects
try
  matlab_version=version('-release');
catch err
  error('%s. See MATLAB Solution ID 1-5JUPSQ and restart MATLAB.',err.message);
end
if(str2double(matlab_version(1:4))<2008)
  error('requires MATLAB version 2008a or greater');
end

% add component repository to the path
componentPath=fullfile(fileparts(mfilename('fullpath')),'components');
addpath(componentPath);
fprintf('\npath added: %s',componentPath);

% create an instance of TOMMAS
tom=tommas;

% create an instance of the GUI
gui=mainDisplay;

% optimize forever
for index=1:inf
  % get the latest trajectory and cost estimates
  [x,cost]=getResults(tom);

  % update graphical display
  put(gui,x,cost,index);

  % take an optimization step
  step(tom);
end
