classdef DemoConfig < handle
  properties (Constant=true,GetAccess=public)
    % select hardware resource or data container
    dataURI = 'matlab:MiddleburyData';
    
    % select default dynamic model
    dynamicModelName = 'LinearKalmanDynamicModel';
    
    % select default optimizer
    optimizerName = 'LinearKalmanOptimizer';
        
    % select default measures
    measureNames = {'LinearKalmanMeasure'};
  end 
end
