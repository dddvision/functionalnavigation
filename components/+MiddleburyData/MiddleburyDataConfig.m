classdef MiddleburyDataConfig  < handle
  properties (Constant=true,GetAccess=protected)
    sceneYear = 'scenes2005'; % 'scenes2005', 'scenes2006'
    fractionalSize = 'HalfSize'; % 'FullSize', 'HalfSize', 'ThirdSize'   
    scene = 'Art'; % 'Art', 'Books', 'Aloe', ...}
    illumination = 'Illum2'; % 'Illum1', 'Illum2', 'Illum3'
    exposure = 'Exp1'; % 'Exp0', 'Exp1', 'Exp2'
    fps = 3; % (3) frames per second
    numImages = 7; % (7) number of images
  end
end
