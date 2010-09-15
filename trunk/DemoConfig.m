classdef DemoConfig < handle
  
  properties (Constant=true,GetAccess=public)
    uri = 'matlab:MiddleburyData'; % ('matlab:MiddleburyData') select hardware resource or data container
    dynamicModelName = 'Default'; % ('Default') name of a single DynamicModel component
    measureNames = {'Default'}; % ({'Default'}) cell array of zero or more names of Measure component
    optimizerName = 'Default'; % ('Default') name of a single Optimizer component
    defaultInitialTime = tom.WorldTime(0); % (tom.WorldTime(0)) default initial time when no data is available
    numTrajectories = 10; % (10) number of trajectories to use for optimization
    numSteps = uint32(1E9); % (uint32(1E9)) number of optimization steps until termination
    textOnly = false; % (true) show text output only
    bestOnly = false; % (true) show only the best trajectory
    saveFigure = false; % (false) saves figure as an image
    width = 640; % (640) figure width in pixels
    height = 480; % (480) figure height in pixels
    gamma = 2; % (2) nonlinearity of trajectory transparency
    scale = 0.01; % (0.01) scale of body frame
    bigSteps = 10; % (10) number of body frames per trajectory
    subSteps = 10; % (10) number of line segments between body frames
    infinity = 100; % (100) replaces infinity as a time domain upper bound
    colorBackground = [1,1,1]; % ([1,1,1]) color of figure background
    colorHighlight = [1,0,0]; % ([1,0,0]) color of objects to emphasize
    colorReference = [0,1,0]; % ([0,1,0]) color of reference objects
  end
  
end
