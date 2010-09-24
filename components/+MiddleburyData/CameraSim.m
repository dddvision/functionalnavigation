classdef CameraSim < MiddleburyData.MiddleburyDataConfig & Camera
  
  properties
    ring
    ringsz
    base
    na
    nb
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
      for n=1:this.ringsz
        this.ring{n}.time=tom.WorldTime(double(n-1)/this.fps);
        this.ring{n}.image=getMiddleburyArt(this,n-1);
      end
      this.rho=1;
      this.base=uint32(1);
      this.na=uint32(1);
      this.nb=uint32(this.numImages);
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
    
    function na=first(this)
      assert(this.ready)
      na=this.na;
    end

    function nb=last(this)
      assert(this.ready)
      nb=this.nb;
    end
    
    function time=getTime(this,n)
      assert(this.ready);
      assert(n>=this.na);
      assert(n<=this.nb);
      time=this.ring{ktor(this,n)}.time;
    end
    
    function [numStrides,numSteps,numLayers]=getImageSize(this,n,varargin)
      assert(this.ready);
      assert(n>=this.na);
      assert(n<=this.nb);
      numStrides=this.N;
      numSteps=this.M;
      numLayers=length(this.layers);
    end
    
    function im=getImage(this,n,varargin)
      assert(this.ready);
      assert(n>=this.na);
      assert(n<=this.nb);
      im=this.ring{ktor(this,n)}.image;
    end
    
    function str=interpretLayers(this,varargin)
      str=this.layers;
    end
    
    function flag=isFrameDynamic(this,varargin)
      flag=this.frameDynamic;
    end
    
    function pose=getFrame(this,varargin)
      pose.p=this.frame(1:3);
      pose.q=this.frame(4:7);
      pose=tom.Pose(pose);
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
      r=mod(this.base+k-this.na-uint32(1),this.ringsz)+uint32(1);
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
        if(this.verbose)
          fprintf('\ncaching: %s',url);
        end
        urlwrite(url,fcache);
      end
      rgb=imread(fcache);
    end
  end
  
end

