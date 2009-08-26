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
    
    function bits=dynamicGet(this,tmin)
      bits=this.focalPerturbation;
    end
    
    function this=dynamicPut(this,bits,tmin)
      fprintf('\n');
      fprintf('\ncameraOpticalFlow1::dynamicPut');
      fprintf('\nbits = ');
      fprintf('%d',bits);
      this.focalPerturbation=bits;
    end
    
    function cost=priorCost(this,bits,tmin)
      cost=zeros(size(bits,1),1);
    end
        
  end
end
