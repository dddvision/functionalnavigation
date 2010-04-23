classdef CameraSim < MiddleburyData.MiddleburyDataConfig & Camera
  
  properties
    ring
    ringsz
    base
    ka
    kb
    rho
    frame
    M
    N
    layers
    frameDynamic
    projectionDynamic
    ready
  end
  
  methods (Access=public)
    function this=CameraSim
      this.ringsz=uint32(this.numImages);
      for k=1:this.ringsz
        this.ring{k}.time=WorldTime(double(k-1)/this.fps);
        this.ring{k}.image=getMiddleburyArt(this,k-1);
      end
      this.rho=1;
      this.base=uint32(1);
      this.ka=uint32(1);
      this.kb=uint32(this.numImages);
      this.M=uint32(size(this.ring{1}.image,1));
      this.N=uint32(size(this.ring{1}.image,2)); 
      this.layers='rgb';
      this.frameDynamic=false;
      this.projectionDynamic=false;
      this.frame=[0;0;0;1;0;0;0];
      this.ready=true;
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
      time=this.ring{ktor(this,k)}.time;
    end
    
    function [numStrides,numSteps,numLayers]=getImageSize(this,k,varargin)
      assert(this.ready);
      assert(k>=this.ka);
      assert(k<=this.kb);
      numStrides=this.N;
      numSteps=this.M;
      numLayers=length(this.layers);
    end
    
    function im=getImage(this,k,varargin)
      assert(this.ready);
      assert(k>=this.ka);
      assert(k<=this.kb);
      im=this.ring{ktor(this,k)}.image;
    end
    
    function str=interpretLayers(this,varargin)
      str=this.layers;
    end
    
    function flag=isFrameDynamic(this,varargin)
      flag=this.frameDynamic;
    end
    
    function [p,q]=getFrame(this,varargin)
      p=this.frame(1:3);
      q=this.frame(4:7);
    end
    
    function flag=isProjectionDynamic(this,varargin)
      flag=this.projectionDynamic;
    end
    
    function pix=projection(this,ray,varargin)
      m=double(this.M);
      n=double(this.N);
      coef=this.rho./ray(1,:);
      u1=((n-1)/(m-1))*coef.*ray(3,:);
      u2=coef.*ray(2,:);
      pix=[(u2+1)*((n-1)/2);
           (u1+1)*((m-1)/2)];
    end
    
    function ray=inverseProjection(this,pix,varargin)
      m=double(this.M);
      n=double(this.N);
      u1=((m-1)/(n-1))*(pix(2,:)*(2/(m-1))-1);
      u2=pix(1,:)*(2/(n-1))-1;
      den=sqrt(u1.*u1+u2.*u2+this.rho*this.rho);
      ray=[this.rho./den;u2./den;u1./den];
    end
  end
  
  methods (Access=private)
    function r=ktor(this,k)
      r=mod(this.base+k-this.ka-uint32(1),this.ringsz)+uint32(1);
    end
    
    function rgb=getMiddleburyArt(this,num)
      repository='http://vision.middlebury.edu/stereo/data/';
      cache=[fileparts(mfilename('fullpath')),'/'];
      subdir=[this.sceneYear,'/',this.fractionalSize,'/',this.scene,'/',...
              this.illumination,'/',this.exposure,'/'];
      view=sprintf('view%d.png',num);
      fcache=fullfile(cache,subdir,view);
      dircache=[cache,subdir];
      if(~exist(dircache,'file'))
        mkdir(dircache);
      end
      if(~exist(fcache,'file'))
        url=[repository,subdir,view];
        fprintf('\ncaching: %s',url);
        urlwrite(url,fcache);
      end
      rgb=imread(fcache);
    end
  end
  
end

