classdef MacBookBuiltInSensorsConfig < handle
  properties (Constant=true)
    
    % path to VLC Media Player for OS X ('/Applications/VLC.app/Contents/MacOS/VLC')
    vlcPath='/Applications/VLC.app/Contents/MacOS/VLC';
    
    % number of frames to advance per data node (10)
    cameraIncrement=1;
    
    % position offset in meters of camera frame relative to the body frame ([0;0.1;0.2])
    cameraPositionOffset=[0;0.1;0.2];
    
    % quaternion offset in radians ([1;0;0;0])
    cameraRotationOffset=[1;0;0;0]; 
    
    % maximum time in seconds to wait for individual sensor initialization (10)
    timeOut=10;
    
  end
end
