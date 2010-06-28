classdef MacBookBuiltInSensorsConfig < handle
  properties (Constant=true)
    frameIncrement=2; % (1) number of frames to advance per data node
    overwrite=true; % (true) overwrite cached data, or use previously recorded data
    %rate=0.073502; % (0.073502) seconds per frame
    frameOffset=[0;0;0;1;0;0;0]; % TODO: measure offset of camera frame
    timeOut=5; % (5) seconds to wait for camera to initialize
  end
end
