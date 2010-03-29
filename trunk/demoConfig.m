classdef demoConfig < handle
  properties (Constant=true,GetAccess=public)
    % select hardware resource or data container
    uri = 'matlab:middleburyData';
    
    % select default dynamic model
    dynamicModel = 'linearKalmanDynamicModel';
    
    % select default optimizer
    optimizer = 'linearKalmanOptimizer';
        
    % select default measures
    measures = {'linearKalmanMeasure'};
  end 
end
