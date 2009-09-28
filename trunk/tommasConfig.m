classdef tommasConfig

  properties
    componentPath=fullfile(fileparts(which('main')),'components');
    
    % TODO: support configuration of multiple sensors/measures
    % TODO: measure/sensor compatibility checking
    sensor='cameraSim1';
    trajectory='trajectorystub'; % try 'trajectorystub' or 'lineWobble1'
    measure='opticalFlow1'; % try 'measurestub' or 'opticalFlow1'
    optimizer='optimizerstub'; % try 'optimizerstub' or 'matlabGA1'
  end
    
end
