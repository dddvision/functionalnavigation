classdef opticalFlow1 < measure
  properties (GetAccess=private,SetAccess=private)
    u
    focal
    focalPerturbation
  end
    methods
      
    function this=opticalFlow1
      fprintf('\n');
      fprintf('\nopticalFlow1::opticalFlow1');
      % TODO: get real or simulated data
      this.u=camera;
      this.focal=100;
      this.focalPerturbation=logical(rand(1,8)>=0.5);
    end
        
  end
end
