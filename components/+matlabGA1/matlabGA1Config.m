classdef matlabGA1Config < handle
  
    properties (Constant=true,GetAccess=protected)
      popSizeDefault = 20; % (20) default number of trajectories to test
    
      % start trajectories at this time
      referenceTime = 1/3;
    
      % HACK: should adjust the trajectory domain based on data
      numBlocks = 4;
    end
  
end
