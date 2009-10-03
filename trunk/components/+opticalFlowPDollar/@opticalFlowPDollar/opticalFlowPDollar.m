classdef opticalFlowPDollar < measure
  
  properties (GetAccess=private,SetAccess=private)
    u
  end
  
  methods (Access=public)
    function this=opticalFlowPDollar(u)
      fprintf('\n');
      fprintf('\nopticalFlowPDollar::opticalFlowPDollar');
      % TODO: get real or simulated data
      this.u=u;
    end     
  end
  
end
