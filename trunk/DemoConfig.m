classdef DemoConfig < handle
  properties (Constant = true, GetAccess = public)
    % trajectory optimization parameters
    uri = 'hidi:TrajectorySim'; % ('hidi:MiddleburyTemple') select hardware resource or data container
    dynamicModelName = 'BrownianPlanar'; % ('tom') name of a single DynamicModel component
    measureNames = {'GlobalSatData'}; % ({'tom'}) cell array of zero or more names of Measure components
    optimizerName = 'MatlabGA'; % ('tom') name of a single Optimizer component
    
    % display parameters
    textOnly = false; % (false) show text output only
    bestOnly = false; % (false) show only the best trajectory
    saveFigure = false; % (false) saves figure as an image
    width = 640; % (640) figure width in pixels
    height = 480; % (480) figure height in pixels
    infinity = 1000; % (1000) maximum span of time domain if upper bound is infinite
  end
end
