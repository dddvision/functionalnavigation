classdef opticalFlowPDollar < measure
  
  properties (GetAccess=private,SetAccess=private)
    cameraHandle
  end
  
  methods (Access=public)
    function this=opticalFlowPDollar(cameraHandle)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::opticalFlowPDollar');
      % TODO: get real or simulated data
      this.cameraHandle=cameraHandle;
    end     
  end
  
end
