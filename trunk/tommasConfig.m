classdef tommasConfig

  properties (Constant=true)
    % select dynamic model
    dynamicModel = 'wobble1';
    
    % select optimizer
    optimizer = 'optimizerStub';
  
    % select data container
    dataContainer = 'globalSatData';
    
    % match each measure to a specific sensor class, cell array of structs
    measures = {struct('measure','measureStub','sensor','gps');...
                struct('measure','measureStub','sensor','gps')};
    
    % referenceDate = datestr(now,30);
    popSizeDefault = 10; % (10) default number of trajectories to test
    
    % optimize starting at this time
    tmin=0;
  end
    
end
