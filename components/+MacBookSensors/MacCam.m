classdef MacCam < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & Camera
  
  properties (Access=private)
    path
    localCache
    ka
    kb
    numStrides
    numSteps
    layers
    frameDynamic
    projectionDynamic
    refTime
    initialTime
    rate
    timeOutText
  end
  
  methods (Static=true,Access=public)
    function stop
      unix('killall -9 VLC');
    end
  end
  
  methods (Access=public)
    function this=MacCam(path,localCache)
      this.path=path;
      this.localCache=localCache;
      this.ka=uint32(1);
      this.kb=uint32(2);
      this.numStrides=120;
      this.numSteps=160;
      this.layers='rgb';
      this.frameDynamic=false;
      this.projectionDynamic=false;
      this.timeOutText='timeout while waiting for camera initialization';
      ready=false;
      startcmd=['/Applications/VLC.app/Contents/MacOS/VLC qtcapture:// ',...
        '--vout=dummy --aout=dummy --video-filter=scene --scene-format=png --scene-prefix="" ',...
        sprintf('--scene-width=%d --scene-height=%d ',this.numSteps,this.numStrides),...
        sprintf('--scene-ratio=%d --scene-path=%s ',this.frameIncrement,this.localCache),...
        '2> /dev/null &'];
      unix(startcmd);
      t0=clock; 
      t1=clock;
      while(etime(t1,t0)<this.timeOut)
        t1=clock;
        if(isValid(this,uint32(1)))
          ready=true;
          break;
        end
      end
      if(~ready)
        error(this.timeOutText);
      end
      ready=false;
      t2=clock;
      while(etime(t2,t1)<(this.timeOut+0.1*this.frameIncrement))
        t2=clock;
        if(isValid(this,uint32(2)))
          ready=true;
          break;
        end
      end
      if(~ready)
        error(this.timeOutText);
      end
      this.initialTime=etime(t1,[1980,1,6,0,0,0]);
      this.rate=etime(t2,t1);
      this.refTime=t1;
    end

    function refresh(this)
      kRef=this.kb;
      while(isValid(this,this.kb+uint32(1)))
        this.kb=this.kb+uint32(1);
      end
      if(this.kb>kRef)
        this.rate=etime(clock,this.refTime)/double(this.kb-this.ka);
      end
    end
    
    function flag=hasData(this)
      assert(isa(this,'Camera'));
      flag=true;
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
      num=this.ka+this.frameIncrement*k;
      im=imread(fullfile(this.localCache,sprintf('%05d.png',num)));
    end
    
    function flag=isFrameDynamic(this,varargin)
      flag=this.frameDynamic;
    end
    
    function [p,q]=getFrame(this,k,varargin)
      assert(k>=this.ka);
      assert(k<=this.kb);
      p=this.frameOffset(1:3);
      q=this.frameOffset(4:7);
    end
        
    function flag=isProjectionDynamic(this,varargin)
      flag=this.projectionDynamic;
    end

    function pix=projection(this,ray,varargin)
      % MacBook camera has approximately 64 degrees horizontal FOV
      % Appears to be equal angular increments for each pixel
      c1=ray(1,:);
      c2=ray(2,:);
      c3=ray(3,:);
      m=this.numStrides;
      n=this.numSteps;
      mc=m/2;
      nc=n/2;
      dpp=64/n;
      rpp=pi/180*dpp;
      r=acos(c1)/rpp;
      theta=atan2(c3,c2);
      pn=r.*cos(theta)+nc;
      pm=r.*sin(theta)+mc;
      behind=find((c1<=0)|(pm<0)|(pn<0)|(pn>=n)|(pm>=m));
      pm(behind)=NaN;
      pn(behind)=NaN;
      pix=[pn;pm];
    end
    
    function ray=inverseProjection(this,pix,varargin)
      m=this.numStrides;
      n=this.numSteps;
      mc=m/2;
      nc=n/2;
      pm=pix(2,:)-mc;
      pn=pix(1,:)-nc;
      r=sqrt(pm.*pm+pn.*pn);
      theta=atan2(pm,pn);
      dpp=64/n;
      rpp=pi/180*dpp;
      alpha=r/rpp;
      c1=cos(alpha);
      c2=cos(theta).*sin(alpha);
      c3=cos(theta).*cos(alpha);
      ray=[c1;c2;c3];
    end
end
  
  methods (Access=private)
    function flag=isValid(this,k)
      num=this.ka+this.frameIncrement*k;
      fname=fullfile(this.localCache,sprintf('%05d.png',num));
      flag=exist(fname,'file');
    end
    
    function delete(this)
      this.stop;
    end
  end
end
