classdef DemoDisplayConfig < handle
  properties (Constant=true,GetAccess=public)
    bestOnly=true; % (true) show only the best trajectory
    saveFigure=false; % (false) saves figure as an image
    width=640; % (640) figure width in pixels
    height=480; % (480) figure height in pixels
    gamma=2; % (2) nonlinearity of trajectory transparency
    scale=0.005; % (0.005) scale of body frame
    bigSteps=10; % (10) number of body frames per trajectory
    subSteps=10; % (10) number of line segments between body frames
    infinity=10; % (1e6) replaces infinity as a time domain upper bound
    colorBackground = [1,1,1]; % ([1,1,1]) color of figure background
    colorHighlight = [1,0,0]; % ([1,0,0]) color of objects to emphasize
    colorReference = [0,1,0]; % ([0,1,0]) color of reference objects
  end
end
