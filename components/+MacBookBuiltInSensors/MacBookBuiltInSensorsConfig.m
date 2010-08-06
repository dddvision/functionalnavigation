classdef MacBookBuiltInSensorsConfig < handle
  properties (Constant=true)
    % Camera frame offset relative to the accelerometer frame
    %   Camera frame is forward-right-down
    %   Default accelerometer frame
    %     axis 0 points to the user's right
    %     axis 1 points away from the user in the forward direction
    %     axis 2 points upward
    cameraPositionOffset=[0;0.1;0.2]; % position offset in meters ([0;0.1;0.2])
    cameraRotationOffset=[0;1;-1;0]/sqrt(2); % quaternion offset in radians ([0;1;-1;0]/sqrt(2))
    
    % Camera horizontal field of view in radians (56/180*pi)
    cameraFieldOfView=56/180*pi;
    
    % Number of frames to advance per data index (10)
    cameraIncrement=10;
    
    % Path to VLC Media Player for OS X ('/Applications/VLC.app/Contents/MacOS/VLC')
    vlcPath='/Applications/VLC.app/Contents/MacOS/VLC';
    
    % Path to temporary folder for caching data (fullfile(fileparts(mfilename('fullpath')),'tmp'))
    localCache=fullfile(fileparts(mfilename('fullpath')),'tmp');
    
    % Maximum time in seconds to wait for individual sensor initialization (10)
    timeOut=10;
    
    % display warnings and other diagnostic information (false)
    verbose=false; 
  end
end
