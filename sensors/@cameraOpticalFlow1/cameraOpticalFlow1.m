classdef cameraOpticalFlow1 < sensor
  properties (GetAccess=private,SetAccess=private)
    focalPerturbation
    index
    time
    focal
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
    
    function this=staticPut(this,bits)
      fprintf('\n');
      fprintf('\ncameraOpticalFlow1::staticPut');
      fprintf('\nbits = ');
      fprintf('%d',bits);
      this.focalPerturbation=bits;
    end
 
    function bits=staticGet(this)
      bits=this.focalPerturbation;
    end
    
    function bits=dynamicGet(this,tmin)
      bits=zeros(1,0);
    end
    
    function cost=priorCost(this,staticBits,dynamicBits,tmin)
      cost=0;
    end

    function this=dynamicPut(this,bits,tmin)
      % do nothing
    end
        
  end
end
