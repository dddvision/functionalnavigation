classdef middleburyDataConfig  < handle
  properties (Constant=true,GetAccess=protected)
    sceneYear = 'scenes2005'; % 'scenes2005', 'scenes2006'
    fractionalSize = 'ThirdSize'; % 'FullSize', 'HalfSize', 'ThirdSize'   
    scene = 'Art'; % 'Art', 'Books', 'Aloe', ...}
    illumination = 'Illum2'; % 'Illum1', 'Illum2', 'Illum3'
    exposure = 'Exp1'; % 'Exp0', 'Exp1', 'Exp2'
    fps = 3; % (3) frames per second
  end
end