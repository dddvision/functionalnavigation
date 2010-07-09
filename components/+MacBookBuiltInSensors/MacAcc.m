classdef MacAcc < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & AccelerometerArray
  
  properties (Constant=true)
    ka=uint32(0);
    nAxes=uint32(3);
    smsLib='smslib.m';
    smsCode='smsutil.m';
    smsApp='smsapp';
    smsLog='sms.csv';
    compilerFlags='-arch x86_64 -ObjC -framework Foundation -framework IOKit -Wall';
    smsFlags='-i0 -c0 -atxyz -s44'; % 40 bytes per line
    lineSkip=40;
    clockBase=[1980,1,6,0,0,0];
    timeOutText='Timeout while waiting for accelerometer initialization';
    indexErrorText='Accelerometer axis index is out of range';
  end
  
  properties (Access=private)
    fid
    kb
    ready
    initialTime
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
      
      smsLibPath=fullfile(thisPath,this.smsLib);
      smsCodePath=fullfile(thisPath,this.smsCode);
      smsAppPath=fullfile(thisPath,this.smsApp);
      smsLogPath=fullfile(localCache,this.smsLog);
      
      if(~exist(smsAppPath,'file'))
        unix(sprintf('g++ %s %s %s -o %s',this.compilerFlags,smsLibPath,smsCodePath,smsAppPath));
      end
      unix(sprintf('%s %s > %s &',smsAppPath,this.smsFlags,smsLogPath));
      
      % ensure that sms log file exists
      this.ready=false;
      t0=clock;
      t1=clock;
      while(etime(t1,t0)<this.timeOut)
        if(exist(smsLogPath,'file'))
          t1=clock;
          this.ready=true;
          break;
        end
        t1=clock;
      end
      if(~this.ready)
        error(this.timeOutText);
      end
      this.initialTime=etime(t1,this.clockBase);
      this.fid=fopen(smsLogPath,'r');
      
      % ensure that exactly two measurements are available
      this.ready=false;
      while(etime(t1,t0)<this.timeOut)
        refresh(this);
        if(last(this)>=uint32(1))
          this.ready=true;
          break;
        end
        t1=clock;
      end
      if(~this.ready)
        error(this.timeOutText);
      end
      this.kb=uint32(1);
    end
    
    function refresh(this)
      fseek(this.fid,0,1);
      sz=ftell(this.fid);
      this.kb=uint32(max(0,floor(sz/this.lineSkip)-1));
    end
    
    function flag=hasData(this)
      flag=this.ready;
    end
    
    function ka=first(this)
      ka=this.ka;
    end
    
    function kb=last(this)
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      time=this.initialTime+get(this,k,4);
    end
    
    function specificForce=getSpecificForce(this,k,ax)
      if((ax>0)&&(ax>2))
        error(this.indexErrorText);
      end
      specificForce=get(this,k,ax);
    end
    
    function num=numAxes(this)
      num=this.nAxes;
    end

    function [offset,direction]=getAxis(this,ax)
      if((ax>0)&&(ax>2))
        error(this.indexErrorText);
      end
      offset=[0;0;0];
      direction=zeros(3,1);
      direction(ax+1)=1;
    end
  end
  
  methods (Access=private)
    function v=get(this,k,ax)
      persistent pk pt pax pay paz
      if(isempty(pk)||(k~=pk))
        assert(k>=this.ka);
        assert(k<=this.kb);
        pk=k;
        fseek(this.fid,40*k,-1);
        s=fgetl(this.fid);
        pt=str2double(s(1:12));
        pax=str2double(s(14:21));
        pay=str2double(s(23:30));
        paz=str2double(s(32:39));
      end
      switch(ax)
        case uint32(0)
          v=pax;
        case uint32(1)
          v=pay;
        case uint32(2)
          v=paz;
        otherwise
          v=pt;
      end
    end
      
    function delete(this)
      this.stop;
    end
  end
end
