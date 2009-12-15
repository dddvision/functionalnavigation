classdef tommasConfig < handle

  properties (Constant=true,GetAccess=public)
    % select dynamic model
    dynamicModel = 'wobble1';
    
    % select optimizer
    optimizer = 'optimizerStub';
  
    % select data container
    dataURI = 'matlab:middleburyData.middleburyData';
    
    % select measures
    measures = {'measureStub','opticalFlowLK'};
    
    % referenceDate = datestr(now,30);
    popSizeDefault = 10; % (10) default number of trajectories to test
    
    % optimize starting at this time
    tmin=0;
  end
    
end
