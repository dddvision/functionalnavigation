classdef MiddleburyDataConfig  < handle
  properties (Constant = true, GetAccess = protected)
    % scene selection parameters
    sceneYear = 'scenes2005'; % 'scenes2005', 'scenes2006'
    fractionalSize = 'ThirdSize'; % 'FullSize', 'HalfSize', 'ThirdSize'   
    scene = 'Art'; % 'Art', 'Books', 'Aloe', ...}
    illumination = 'Illum2'; % 'Illum1', 'Illum2', 'Illum3'
    exposure = 'Exp1'; % 'Exp0', 'Exp1', 'Exp2'
    numImages = uint32(7); % (uint32(7)) number of images

    % simulation parameters
    fps = 3; % (3) frames per second
    secondsPerRefresh = 1; % (1) seconds per call to the refresh function
    
    % diagnostic parameters
    verbose = false; % (false) display warnings and other diagnostic information
  end
end
