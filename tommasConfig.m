classdef tommasConfig < handle

  properties (Constant=true,GetAccess=protected)
    % select dynamic model
    dynamicModel = 'dynamicModelStub';
    
    % select optimizer
    optimizer = 'optimizerStub';
  
    % select data container
    dataURI = 'matlab:middleburyData.middleburyData';
        
    % select measures
    measures = {'measureStub'};
  end
    
end
