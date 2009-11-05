% TODO: support configuration of multiple sensors/measures
% TODO: measure/sensor compatibility checking
% TODO: reference all trajectories to reference date
classdef tommasConfig

  properties (Constant=true)
    % select testbed components
    dataContainer = 'thesisDataDDiel';
    dynamicModel = 'wobble1';
    measure = 'opticalFlowLK';
    optimizer = 'matlabGA1';
    
    % referenceDate = datestr(now,30);
    popSizeDefault = 10; % (10) default number of trajectories to test
  end
    
end
