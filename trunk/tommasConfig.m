classdef tommasConfig

  properties (GetAccess=public,SetAccess=private)
    componentPath=fullfile(fileparts(which('main')),'components');
    
    % TODO: support configuration of multiple sensors/measures
    % TODO: measure/sensor compatibility checking
    multiSensor='middleburyData';
    trajectory='wobble1'; % try 'trajectoryStub' or 'wobble1'
    measure='opticalFlowPDollar'; % try 'measureStub' or 'opticalFlowPDollar'
    optimizer='matlabGA1'; % try 'optimizerStub' or 'matlabGA1'
    
    popSizeDefault=10; % (10) default number of trajectories to test
  end
    
end
