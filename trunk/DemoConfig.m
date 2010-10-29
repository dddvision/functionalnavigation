classdef DemoConfig < handle
  
  properties (Constant = true, GetAccess = public)
    % trajectory optimization parameters
    uri = 'antbed:MiddleburyData'; % ('antbed:MiddleburyData') select hardware resource or data container
    dynamicModelName = 'tom'; % ('tom') name of a single DynamicModel component
    measureNames = {'tom'}; % ({'tom'}) cell array of zero or more names of Measure components
    optimizerName = 'tom'; % ('tom') name of a single Optimizer component
    numSteps = uint32(1E9); % (uint32(1E9)) number of optimization steps until termination
    
    % display parameters
    textOnly = false; % (true) show text output only
    bestOnly = false; % (true) show only the best trajectory
    saveFigure = false; % (false) saves figure as an image
    width = 640; % (640) figure width in pixels
    height = 480; % (480) figure height in pixels
    gamma = 2; % (2) nonlinearity of trajectory transparency
    scale = 0.01; % (0.01) scale of body frame
    bigSteps = 10; % (10) number of body frames per trajectory
    subSteps = 10; % (10) number of line segments between body frames
    infinity = 1000; % (1000) maximum span of time domain if upper bound is infinite
    colorBackground = [1, 1, 1]; % ([1, 1, 1]) color of figure background
    colorHighlight = [1, 0, 0]; % ([1, 0, 0]) color of objects to emphasize
    colorReference = [0, 1, 0]; % ([0, 1, 0]) color of reference objects
  end
  
end
