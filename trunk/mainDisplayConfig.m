classdef mainDisplayConfig
  properties (Constant=true,GetAccess=protected)
    saveFigure=false; % (false) saves figure as an image
    width=500; % (500) figure width in pixels
    height=500; % (500) figure height in pixels
    gamma=4; % (4) nonlinearity of trajectory transparency
    scale=0.01; % (0.01) scale of body frame
    bigSteps=10; % (10) number of body frames per trajectory
    subSteps=10; % (10) number of line segments between frames
    colorBackground = [1,1,1]; % ([1,1,1]) color of figure background
    colorHighlight = [1,0,0]; % ([1,0,0]) color of objects to emphasize
    colorReference = [0,1,0]; % ([0,1,0]) color of reference objects
  end
end
