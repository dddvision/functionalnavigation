classdef MiddleburyTempleConfig  < handle
  properties (Constant = true, GetAccess = protected)
    % repository URL including ending '/' ('http://vision.middlebury.edu/mview/data/data/')
    repository = 'http://vision.middlebury.edu/mview/data/data/';
    
    % data selection    
    dataSetName = 'temple';
    fileStub = 'temple';
    poseList = [262:-1:257, 276:-1:272, 90:105, 85:89, 271:-1:263];
    
    % simulation parameters
    scale = 100; % (100) translation scale multiplier
    fps = 0.5; % (0.5) frames per second
    secondsPerRefresh = 1; % (1) seconds per call to the refresh function
    
    % display warnings and other diagnostic information (true)
    verbose = true; % (true)
  end
end
