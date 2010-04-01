classdef ObjectiveConfig < handle
  properties (Constant=true,GetAccess=public)
    % select hardware resource or data container
    uri = 'matlab:MiddleburyData';
    
    % select dynamic model
    dynamicModelName = 'LinearKalmanDynamicModel';
        
    % select measures
    measureNames = {'LinearKalmanMeasure'};
  end 
end
