classdef MacCam < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & Camera
  
  properties (Constant=true)
    numSteps=120;
    numStrides=160;
    layers='rgb';
    frameDynamic=false;
    projectionDynamic=false;
    clockBase=[1980,1,6,0,0,0];
    fileFormat='%05d.png';
    vlcErrorText='MacBook camera depends on VLC Media Player for OS X';
    timeOutText='Timeout while waiting for camera initialization';
  end
  
  properties (Access=private)
    path
    localCache
    ka
    kb
    focal
    refTime
    initialTime
    rate
    ready
  end
  
  methods (Static=true,Access=public)
    % Stops the image capture process
    function stop
      unix('killall -9 VLC');
    end
  end
  
  methods (Access=public)
    function this=MacCam(thisPath,localCache)
      this=this@Camera;
      fprintf('\nInitializing %s\n',class(this));
      
      this.path=thisPath;
      this.localCache=localCache;
      this.ka=uint32(1);
      this.kb=uint32(2);
      this.focal=this.numStrides*cot(this.cameraFieldOfView/2);
      
      if(~exist(this.vlcPath,'file'))
        error(this.vlcErrorText);
      end
      startcmd=[sprintf('%s qtcapture:// ',this.vlcPath),...
        '--vout=dummy --aout=dummy --video-filter=scene --scene-format=png --scene-prefix="" ',...
        sprintf('--scene-width=%d --scene-height=%d ',this.numStrides,this.numSteps),...
        sprintf('--scene-ratio=%d --scene-path=%s ',this.cameraIncrement,this.localCache),...
        '2> /dev/null &'];
      unix(startcmd);
      
      this.ready=false;
      t0=clock;
      t1=clock;
      while(etime(t1,t0)<this.timeOut)
        if(isValid(this,uint32(1)))
          t1=clock;
          this.ready=true;
          break;
        end
        t1=clock;
      end
      if(~this.ready)
        error(this.timeOutText);
      end
      this.ready=false;
      t2=clock;
      while(etime(t2,t1)<(this.timeOut+0.2*this.cameraIncrement))
        if(isValid(this,uint32(2)))
          t2=clock;
          this.ready=true;
          break;
        end
        t2=clock;
      end
      if(~this.ready)
        error(this.timeOutText);
      end
      this.rate=etime(t2,t1);
      this.initialTime=etime(t1,this.clockBase)-this.rate;
      this.refTime=t1;
    end

    function refresh(this)
      kRef=this.kb;
      while(isValid(this,this.kb+uint32(1)))
        time=clock;
        this.kb=this.kb+uint32(1);
      end
      if(this.kb>kRef)
        numImages=double(this.kb-this.ka+uint32(1)); % adds 1 to account for isValid
        this.rate=etime(time,this.refTime)/numImages; 
      end
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
      assert(k>=this.ka);
      assert(k<=this.kb);
      time=this.initialTime+this.rate*double(k-this.ka);
    end

    function str=interpretLayers(this,varargin)
      str=this.layers;
    end
    
    function [numStrides,numSteps,numLayers]=getImageSize(this,k,varargin)
      assert(k>=this.ka);
      assert(k<=this.kb);
      numStrides=this.numStrides;
      numSteps=this.numSteps;
      numLayers=length(this.layers);
    end
    
    function im=getImage(this,k,varargin)
      assert(k>=this.ka);
      assert(k<=this.kb);
      num=this.ka+this.cameraIncrement*k;
      im=imread(fullfile(this.localCache,sprintf(this.fileFormat,num)));
    end
    
    function flag=isFrameDynamic(this,varargin)
      flag=this.frameDynamic;
    end
    
    function [p,q]=getFrame(this,k,varargin)
      assert(k>=this.ka);
      assert(k<=this.kb);
      p=this.cameraPositionOffset;
      q=this.cameraRotationOffset;
    end
        
    function flag=isProjectionDynamic(this,varargin)
      flag=this.projectionDynamic;
    end

    % MacBook camera has approximately 64 degrees horizontal FOV
    function pix=projection(this,ray,varargin)
      c1=ray(1,:);
      c2=ray(2,:);
      c3=ray(3,:);
      m=this.numSteps;
      n=this.numStrides;
      mc=m/2;
      nc=n/2;
      c1((c1<=0)|(c1>1))=NaN;
      r=this.focal*sqrt(1-c1.*c1)./c1; % r=f*tan(acos(c1))
      theta=atan2(c3,c2);
      pm=r.*sin(theta)+mc;
      pn=r.*cos(theta)+nc;
      outside=((-0.5>pm)|(-0.5>pn)|(pn>(n-0.5))|(pm>(m-0.5)));
      pm(outside)=NaN;
      pn(outside)=NaN;
      pix=[pn;pm];
    end
    
    function ray=inverseProjection(this,pix,varargin)
      m=this.numSteps;
      n=this.numStrides;
      mc=m/2;
      nc=n/2;
      pm=pix(2,:);
      pn=pix(1,:);
      outside=((-0.5>pm)|(-0.5>pn)|(pn>(n-0.5))|(pm>(m-0.5)));
      pm(outside)=NaN;
      pn(outside)=NaN;
      pm=pm-mc;
      pn=pn-nc;
      r=sqrt(pm.*pm+pn.*pn);
      alpha=atan(r/this.focal);
      theta=atan2(pm,pn);
      c1=cos(alpha);
      c2=sin(alpha).*cos(theta);
      c3=sin(alpha).*sin(theta);
      ray=[c1;c2;c3];
    end
end
  
  methods (Access=private)
    % the next image must exist for isValid to be true
    function flag=isValid(this,k)
      num=this.ka+this.cameraIncrement*(k+1); % adds one
      fname=fullfile(this.localCache,sprintf(this.fileFormat,num));
      flag=exist(fname,'file');
    end
    
    function delete(this)
      this.stop;
    end
  end
end
