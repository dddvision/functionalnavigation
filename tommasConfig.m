classdef tommasConfig < handle

  properties (Constant=true,GetAccess=public)
    % select data container
    defaultDataURI = 'matlab:middleburyData.middleburyData';
    
    % select default dynamic model
    defaultDynamicModel = 'dynamicModelStub';
    
    % select default optimizer
    defaultOptimizer = 'matlabGA1';
        
    % select default measures
    defaultMeasures = {'opticalFlowOpenCV'};
  end
    
end
