classdef cameraOpticalFlow1 < sensor
  properties (GetAccess=private,SetAccess=private)
    index
    time
    focal
    focalPerturbation
  end
    methods
      
    function this=cameraOpticalFlow1
      fprintf('\n');
      fprintf('\ncameraOpticalFlow1::cameraOpticalFlow1');
      this.index=[3,4,5]; % TODO: get data from sensor or simulator
      this.time=[1.2,1.4,1.6]; % TODO: get data from sensor or simulator
      this.focal=100;  % TODO: get data from sensor or simulator
      this.focalPerturbation=logical(rand(1,8)>=0.5);
    end
        
  end
end
