classdef opticalFlow1 < measure
  properties (GetAccess=private,SetAccess=private)
    index
    time
    focal
    focalPerturbation
  end
    methods
      
    function this=opticalFlow1
      fprintf('\n');
      fprintf('\nopticalFlow1::opticalFlow1');
      this.index=[3,4,5]; % TODO: get real or simulated data
      this.time=[1.2,1.4,1.6]; % TODO: get real or simulated data
      this.focal=100;  % TODO: get real or simulated data
      this.focalPerturbation=logical(rand(1,8)>=0.5);
    end
        
  end
end
