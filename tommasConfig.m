classdef tommasConfig < handle
  properties (Constant=true,GetAccess=public)
    % select hardware resource or data container
    defaultURI = 'matlab:middleburyData.middleburyData';
    
    % select default dynamic model
    defaultDynamicModel = 'linearKalmanDynamicModel';
    
    % select default optimizer
    defaultOptimizer = 'matlabGA1';
        
    % select default measures
    defaultMeasures = {'opticalFlowOpenCV'};
  end 
end
