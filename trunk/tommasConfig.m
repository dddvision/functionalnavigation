% TODO: measure/sensor compatibility checking
% TODO: reference all trajectories to reference date
classdef tommasConfig

  properties (Constant=true)
    % select dynamic model
    dynamicModel = 'wobble1';
    
    % select optimizer
    optimizer = 'matlabGA1';
  
    % select data container
    dataContainer = 'middleburyData';
    
    % match each measure to a specific sensor class, cell array of structs
    measures = {struct('measure','measureStub','sensor','cameraArray');...
                struct('measure','opticalFlowPDollar','sensor','cameraArray')};
    
    % referenceDate = datestr(now,30);
    popSizeDefault = 10; % (10) default number of trajectories to test
  end
    
end
