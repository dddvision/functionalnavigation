% TODO: measure/sensor compatibility checking
% TODO: reference all trajectories to reference date
classdef tommasConfig

  properties (Constant=true)
    % select dynamic model
    dynamicModel = 'wobble1';
    
    % select optimizer
    optimizer = 'matlabGA1';
    
    % match each measure to specific dataContainer and sensor, cell array of structs
    measures = {struct('measure','measureStub','dataContainer','middleburyData','sensor','cameraArray');...
                struct('measure','opticalFlowPDollar','dataContainer','middleburyData','sensor','cameraArray')};
    
    % referenceDate = datestr(now,30);
    popSizeDefault = 10; % (10) default number of trajectories to test
  end
    
end
