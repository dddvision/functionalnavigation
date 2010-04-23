classdef CameraSim < Camera
  
  properties (SetAccess=private,GetAccess=private)
    localCache
    ka
    kb
    tk
    imsize
    cameraType
    layers
    frameDynamic
    frameOffset
    projectionDynamic
    ready
  end
  
  methods (Access=public)
    function this=CameraSim(localCache)
      this.localCache=localCache;
      info=dir(fullfile(localCache,'/color*'));
      fnames=sortrows(cat(1,info(:).name));
      if(isempty(fnames))
        this.ready=false;
      else
        S=load(fullfile(localCache,'workspace.mat'),'T_cam','CAMERA_TYPE','CAMERA_OFFSET');
        this.ka=uint32(str2double(fnames(1,6:11)));
        this.kb=uint32(str2double(fnames(end,6:11)));
        this.tk=GPSTime(S.T_cam);
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
      im=imread([this.localCache,'/color',sprintf('%06d',k),'.png']);
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
      switch(this.cameraType)
        case 2
          m=this.imsize(1);
          n=this.imsize(2);
          c1=ray(1,:);
          c2=ray(2,:);
          c3=ray(3,:);
          ep=1E-9;
          center=find(abs(1-c1)<ep);
          c1(center)=ep;
          scale=(2/pi)*acos(c1)./sqrt(1-c1.*c1);
          scale(center)=0;
          behind=find(c1(:)<=0);
          u1=scale.*c3;
          u2=scale.*c2;
          u1(behind)=NaN;
          u2(behind)=NaN;
          pix=[(u2+1)*((n-1)/2);
               (u1+1)*((m-1)/2)];
        case 4
          thmax=1.570796;
          ic=254.5;
          jc=317.0;
          a1=153.170245942;
          a2=-0.083878888;
          b1=0.149954284;
          b2=-0.06062850;
          c1=-ray(3,:);
          c2=ray(1,:);
          c3=-ray(2,:);
          c1(abs(1-c1)<eps)=eps;
          c1(c1<cos(thmax))=NaN;
          th=acos(c1);
          th2=th.*th;
          r=(a1*th+a2*th2)./(1+b1*th+b2*th2);
          mag=sqrt(c2.*c2+c3.*c3);
          pix=[jc+r.*c2./mag-1;ic+r.*c3./mag-1];
        otherwise
          error('unrecognized camera type');
      end   
      
    end
    
    function ray=inverseProjection(this,pix,varargin)
      switch(this.cameraType)
        case 2
          m=this.imsize(1);
          n=this.imsize(2);
          down=(pix(2,:)+1)*2/(n-1)+(m+1)/(1-n);
          right=(pix(1,:)+1)*(2/(n-1))+(1+n)/(1-n);
          r=sqrt(down.*down+right.*right);
          a=(r>1);
          b=(r==0);
          ca=((r~=0)&(right<0));
          cb=((r~=0)&(right>=0));
          phi=zeros(size(b));
          phi(ca)=pi-asin(down(ca)./r(ca));
          phi(cb)=asin(down(cb)./r(cb));
          theta=r*(pi/2);
          cp=cos(phi);
          ct=cos(theta);
          sp=sin(phi);
          st=sin(theta);
          c1=ct;
          c2=cp.*st;
          c3=sp.*st;
          c1(a)=NaN;
          c2(a)=NaN;
          c3(a)=NaN;
          ray=cat(1,c1,c2,c3);
        case 4
          thmax=1.570796;
          ic=254.5;
          jc=317.0;
          a1=153.170245942;
          a2=-0.083878888;
          b1=0.149954284;
          b2=-0.06062850;
          i=pix(2,:)+1;
          j=pix(1,:)+1;
          j=j-jc;
          i=i-ic;
          r=sqrt(i.*i+j.*j);
          rmax=(a1*thmax+a2*thmax^2)./(1+b1*thmax+b2*thmax^2);
          r(r>rmax)=NaN;
          th=(sqrt(a1^2-2*a1*b1*r+(4*a2+(b1^2-4*b2)*r).*r)-a1+b1*r)./(2*(a2-b2*r));
          c1=cos(th);
          r(r<eps)=1;
          c2=sin(th).*j./r;
          c3=sin(th).*i./r;
          ray=cat(1,c2,-c3,-c1);
        otherwise
          error('unrecognized camera type');
      end      
    end
  end
  
end
