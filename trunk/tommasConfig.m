classdef tommasConfig

  properties (Constant=true)
    componentPath=fullfile(fileparts(which('main')),'components');
    
    % TODO: support configuration of multiple sensors/measures
    % TODO: measure/sensor compatibility checking
    sensorContainer='thesisDataDDiel'; % try 'middleburyData' or 'thesisDataDDiel'
    trajectory='wobble1'; % try 'trajectoryStub' or 'wobble1'
    measure='opticalFlowPDollar'; % try 'measureStub' or 'opticalFlowPDollar'
    optimizer='matlabGA1'; % try 'optimizerStub' or 'matlabGA1'
    
    popSizeDefault=10; % (10) default number of trajectories to test
  end
    
end