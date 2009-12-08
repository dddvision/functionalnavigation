classdef cameraSim < camera
  
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
    isLocked
    layers
    frameDynamic
    projectionDynamic
  end
  
  methods (Access=public)
    function this=cameraSim
      fps=3;
      this.ringsz=uint32(7);
      for k=1:this.ringsz
        this.ring{k}.time=double(k)/fps;
        this.ring{k}.image=getMiddleburyArt(k-1);
      end
      this.rho=1;
      this.base=uint32(1);
      this.ka=uint32(3);
      this.kb=uint32(9);
      this.M=uint32(size(this.ring{1}.image,1));
      this.N=uint32(size(this.ring{1}.image,2)); 
      this.isLocked=false;
      this.layers='rgb';
      this.frameDynamic=false;
      this.projectionDynamic=false;
      this.frame=[0;0;0;1;0;0;0];
    end
    
    function [ka,kb]=dataDomain(this)
      assert(this.isLocked);
      ka=this.ka;
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      assert(k>=this.ka);
      assert(k<=this.kb);
      time=this.ring{ktor(this,k)}.time;
    end
    
    function isLocked=lock(this)
      this.isLocked=true;
      isLocked=this.isLocked;
    end

    function isUnlocked=unlock(this)
      this.isLocked=false;
      isUnlocked=~this.isLocked;
    end
    
    function [numStrides,numSteps,numLayers]=getImageSize(this,k,varargin)
      assert(k>=this.ka);
      assert(k<=this.kb);
      numStrides=this.N;
      numSteps=this.M;
      numLayers=length(this.layers);
    end
    
    function im=getImage(this,k,varargin)
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
  end
  
end

function rgb=getMiddleburyArt(num)
    fname=['view',num2str(num,'%d'),'.png'];
    fcache=fullfile(fileparts(mfilename('fullpath')),fname);
    if(~exist(fcache,'file'))
      url=['http://vision.middlebury.edu/stereo/data/scenes2005/FullSize/Art/Illum2/Exp1/',fname];
      fprintf('\ncaching: %s',url);
      urlwrite(url,fcache);
    end
    rgb=imread(fcache);
  end