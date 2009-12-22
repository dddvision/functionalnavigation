classdef optimizerStubConfig < handle
  
    properties (Constant=true,GetAccess=protected)
      popSizeDefault = 10; % (10) default number of trajectories to test
    
      % start trajectories at this time
      referenceTime = 0;
    
      % trajectory fidelity in bits per second
      bitsPerSecond = 6*32;
    
      % HACK: use variable duration trajectories
      numBlocks = 5;
    end
  
end
