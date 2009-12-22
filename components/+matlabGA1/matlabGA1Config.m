classdef matlabGA1Config < handle
  
    properties (Constant=true,GetAccess=protected)
      popSizeDefault = 10; % (10) default number of trajectories to test
    
      % start trajectories at this time
      referenceTime = 0;
    
      % HACK: should adjust the trajectory domain based on data
      numBlocks = 5;
    end
  
end
