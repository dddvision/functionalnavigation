classdef MacAcc < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & AccelerometerArray
  
  properties (Constant=true, Access=private)
    smsLib='smslib.m';
    smsCode='smsutil.m';
    smsApp='smsapp';
    smsLog='sms.csv';
    timeOutText='Timeout while waiting for accelerometer initialization';
  end
  
  properties (Access=private)
    localCache
  end
  
  methods (Static=true,Access=public)
    function stop
      unix('killall -9 smsapp');
    end
  end
  
  methods (Access=public)
    function this=MacAcc(thisPath,localCache)
      this=this@AccelerometerArray;
      fprintf('\nInitializing %s\n',class(this));
      
      this.localCache=localCache;
      
      smsLibPath=fullfile(thisPath,this.smsLib);
      smsCodePath=fullfile(thisPath,this.smsCode);
      smsAppPath=fullfile(thisPath,this.smsApp);
      smsLogPath=fullfile(localCache,this.smsLog);
      if(~exist(smsAppPath,'file'))
        unix(['g++ -arch x86_64 -ObjC -framework Foundation -framework IOKit -Wall ',...
          sprintf('%s %s -o %s',smsLibPath,smsCodePath,smsAppPath)]);
      end
      smscmd=sprintf('%s -i0 -c0 -atxyz -s44 > %s &',smsAppPath,smsLogPath); % 40 bytes per line
      unix(smscmd);
      t0=clock;
      t1=clock;
      while(etime(t1,t0)<this.timeOut)
        t1=clock;
        if(exist(smsLogPath,'file'))
          ready=true;
          break;
        end
      end
      if(~ready)
        error(this.timeOutText);
      end
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
  
  methods (Access=private)
    function delete(this)
      this.stop;
    end
  end
end
