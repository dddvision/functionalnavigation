classdef opticalFlow1 < measure
  
  properties (GetAccess=private,SetAccess=private)
    u
    focalPerturbation
  end
  
  methods (Access=public)
    function this=opticalFlow1(u)
      fprintf('\n');
      fprintf('\nopticalFlow1::opticalFlow1');
      % TODO: get real or simulated data
      this.u=u;
      this.focalPerturbation=logical(rand(1,8)>=0.5);
    end     
  end
  
end
