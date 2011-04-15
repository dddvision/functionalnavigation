classdef XBOXKinectConfig < handle
  properties (Constant = true)   
    % Kinect depth image horizontal field of view in radians (57.8/180*pi)
    depthFieldOfView = 57.8/180*pi;
    
    % Kinect image horizontal field of view in radians (62.7/180*pi)
    imageFieldOfView = 62.7/180*pi;
    
    % Maximum time in seconds to wait for individual sensor initialization (10)
    timeOut = 10;
    
    % Attempt to recompile the Kinect application used by this component (false)
    recompile = false;
    
    % Overwrite stored images (false)
    overwrite = true;
    
    % display warnings and other diagnostic information (true)
    verbose = true; 
  end
end
