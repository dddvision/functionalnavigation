classdef cameraOpticalFlow1 < sensor
  properties (GetAccess=private,SetAccess=private)
    intrinsicStatic
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
      this.intrinsicStatic=logical(rand(1,8)>=0.5);
    end
    
    function this=setStaticSeed(this,newStaticSeed)
      this.intrinsicStatic=newStaticSeed;
    end
 
    function staticSeed=getStaticSeed(this)
      staticSeed=this.intrinsicStatic;
    end
    
    function subSeed=getDynamicSubSeed(this,tmin,tmax)
      subSeed=zeros(1,0);
    end

    function this=setDynamicSubSeed(this,newSubSeed,tmin,tmax)
      % do nothing
    end
        
  end
end
