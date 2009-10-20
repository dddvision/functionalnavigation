classdef tommasConfig

  properties (Constant=true)
    % TODO: support configuration of multiple sensors/measures
    % TODO: measure/sensor compatibility checking
    dataContainer = 'thesisDataDDiel'; % try 'middleburyData' or 'thesisDataDDiel'
    dynamicModel = 'wobble1'; % try 'dynamicModelStub' or 'wobble1'
    measure = 'opticalFlowPDollar'; % try 'measureStub' or 'opticalFlowPDollar'
    optimizer = 'matlabGA1'; % try 'optimizerStub' or 'matlabGA1'
    
    % TODO: reference all trajectories to reference date
    % referenceDate = datestr(now,30);
    popSizeDefault = 10; % (10) default number of trajectories to test
  end
    
end
