classdef MacAcc < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & AccelerometerArray
  
  methods (Static=true,Access=public)
    function stop
      unix('killall -9 smscustom');
    end
  end
  
  methods (Access=public)
    function this=MacAcc(path,localCache)
      % if(~exist( smscustom...)
      %   unix('g++ -arch x86_64 -ObjC -framework Foundation -framework IOKit -pedantic -Wall smslib.m smscustom.m -o smscustom');
      %./smscustom -i0 -c0 -atxyz -s44 > ./tmp/accel.csv &
    end
    
    function refresh(this)
    end
    
    function flag=hasData(this)
      flag=false;
    end
    
    function ka=first(this)
      ka=uint32(0);
    end
    
    function kb=last(this)
      kb=uint32(0);
    end
    
    function time=getTime(this,k)
      time=0;
    end
    
    function specificForce=getSpecificForce(this,k,ax)
      specificForce=0;
    end
    
    function dt=getIntegrationTime(this)
      dt=0;
    end
    
    function num=numAxes(this)
      num=uint32(3);
    end

    function [offset,direction]=getAxis(this,ax)
      offset=[0;0;0];
      direction=[1;0;0]; % TODO
    end
    
  end
  
end
