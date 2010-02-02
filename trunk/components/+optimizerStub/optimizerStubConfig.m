classdef optimizerStubConfig < handle
  
    properties (Constant=true,GetAccess=protected)
      % Default number of trajectories to test
      popSizeDefault = 20;
    
      % Start all trajectories at this time
      referenceTime = 1/3;
      
      % Look back no more than this far into the past
      dMax = uint32(5);
    
      % Number of parameter blocks supplied to the dynamic model
      numBlocks = 4; % HACK: should adjust based on data
    end
  
end
