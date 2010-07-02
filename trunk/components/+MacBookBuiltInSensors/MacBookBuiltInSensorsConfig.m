classdef MacBookBuiltInSensorsConfig < handle
  properties (Constant=true)
    cameraIncrement=10; % (1) number of frames to advance per data node
    % TODO: measure offset of camera frame
    cameraFrameOffset=[0;0;0;1;0;0;0]; % offset of the camera frame relative to the accelerometer
    timeOut=10; % (10) maximum time in seconds to wait for any stage of sensor initialization
  end
end
