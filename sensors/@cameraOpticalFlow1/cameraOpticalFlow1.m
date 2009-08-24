classdef cameraOpticalFlow1 < sensor
  properties (GetAccess=private,SetAccess=private)
    focalPerturbation
    gray
    index
    time
    focal
  end
    methods
    function this=cameraOpticalFlow1
      fprintf('\n');
      fprintf('\n### cameraOpticalFlow1 constructor ###');
      this.gray=gray_image_init;
      this.index=[3,4,5];
      this.time=[1.2,1.4,1.6];
      this.focal=100;  % TODO: derive focal length from sensor data
      this.focalPerturbation=logical(rand(1,8)>=0.5);
    end
    
    function this=staticSet(this,bits)
      this.focalPerturbation=bits;
    end
 
    function bits=staticGet(this)
      bits=this.focalPerturbation;
    end
    
    function bits=dynamicGet(this,tmin,tmax)
      bits=zeros(1,0);
    end

    function this=dynamicSet(this,bits,tmin,tmax)
      % do nothing
    end
        
  end
end
