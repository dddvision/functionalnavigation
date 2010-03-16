classdef tommasConfig < handle
  properties (Constant=true,GetAccess=public)
    % select data container
    defaultDataURI = 'matlab:middleburyData.middleburyData';
    
    % select default dynamic model
    defaultDynamicModel = 'linearKalmanDynamicModel';
    
    % select default optimizer
    defaultOptimizer = 'linearKalmanOptimizer';
        
    % select default measures
    defaultMeasures = {'linearKalmanMeasure'};
  end 
end
