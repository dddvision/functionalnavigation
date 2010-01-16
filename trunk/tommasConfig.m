classdef tommasConfig < handle

  properties (Constant=true,GetAccess=protected)
    % select dynamic model
    dynamicModel = 'dynamicModelStub';
    
    % select optimizer
    optimizer = 'matlabGA1';
  
    % select data container
    dataURI = 'matlab:middleburyData.middleburyData';
        
    % select measures
    measures = {'pointBasedMeasure'};
  end
    
end
