classdef MacCam < MacBookBuiltInSensors.MacBookBuiltInSensorsConfig & Camera
  
  properties (Access=private)
    
  end
  
  methods (Access=public)
    function this=MacCam
      thisPath=fileparts(mfilename('fullpath'));
      this.localCache=fullfile(thisPath,'tmp');
      if(~exist(this.localCache,'dir'))
        mkdir(this.localCache);
      end
      delete(fullfile(this.localCache,'*.png'));
      this.ka=uint32(0);
      this.kb=uint32(str2double(fnames(end,6:11)));
      this.tk=WorldTime(S.T_cam);
      this.cameraType=S.CAMERA_TYPE;
      this.layers='rgb';
      this.frameDynamic=false;
      this.frameOffset=[S.CAMERA_OFFSET;1;0;0;0];
      this.projectionDynamic=false;
      this.imsize=size(getImage(this,this.ka));
      this.ready=true;
      end
    end

    function refresh(this)
      assert(this.ready);
    end
    
    function flag=hasData(this)      
      flag=this.ready;
    end
    
    function ka=first(this)
      assert(this.ready)
      ka=this.ka;
    end

    function kb=last(this)
      assert(this.ready)
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      assert(this.ready);
      assert(k>=this.ka);
      assert(k<=this.kb);
      time=this.tk(k);
    end

    function str=interpretLayers(this,varargin)
      str=this.layers;
    end
    
    function [numStrides,numSteps,numLayers]=getImageSize(this,k,varargin)
      assert(k>=this.ka);
      assert(k<=this.kb);
      numStrides=this.imsize(2);
      numSteps=this.imsize(1);
      numLayers=length(this.layers);
    end
    
    function im=getImage(this,k,varargin)
      assert(k>=this.ka);
      assert(k<=this.kb);
      num=1+this.frameIncrement*k;
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
      m=this.imsize(1);
      n=this.imsize(2);
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
      m=this.imsize(1);
      n=this.imsize(2);
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
    function flag=imgExist(this,index)
      num=2+this.frameIncrement*index;
      fname=
      flag=exist(fname,'file');
    end
  end
end
