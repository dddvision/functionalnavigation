classdef tommasConfig

  properties
    componentPath=fullfile(fileparts(which('main')),'components');
    
    % TODO: support configuration of multiple sensors/measures
    % TODO: measure/sensor compatibility checking
    sensor='cameraSim1';
    trajectory='lineWobble1'; % try 'trajectorystub' or 'lineWobble1'
    measure='opticalFlow1'; % try 'measurestub' or 'opticalFlow1'
    optimizer='matlabGA1'; % try 'optimizerstub' or 'matlabGA1'
    
    popSizeDefault=10; % (10) default number of trajectories to test
  end
    
end
