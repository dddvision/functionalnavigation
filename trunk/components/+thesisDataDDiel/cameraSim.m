classdef cameraSim < cameraArray
  
  properties (SetAccess=private,GetAccess=private)
    localCache
    isLocked
    ka
    kb
    tk
    imsize
    cameraType
  end
  
  methods (Access=public)
    function this=cameraSim(localCache)
      this.localCache=localCache;
      info=dir(fullfile(localCache,'/color*'));
      fnames=sortrows(cat(1,info(:).name));
      this.ka=uint32(str2double(fnames(1,6:11)));
      this.kb=uint32(str2double(fnames(end,6:11)));
      this.tk=getfield(load(fullfile(localCache,'workspace.mat'),'T_cam'),'T_cam');
      this.isLocked=true;
      this.imsize=size(getImage(this,this.ka));
      this.isLocked=false;
      this.cameraType=getfield(load(fullfile(localCache,'workspace.mat'),'CAMERA_TYPE'),'CAMERA_TYPE');
    end
    
    function [ka,kb]=domain(this)
      assert(this.isLocked);
      ka=this.ka;
      kb=this.kb;
    end
    
    function time=getTime(this,k)
      assert(isa(k,'uint32'));
      assert(this.isLocked);
      time=this.tk(k);
    end
    
    function lock(this)
      this.isLocked=true;
    end

    function unlock(this)
      this.isLocked=false;
    end    
    
    function num=numViews(this)
      num=uint32(1);
    end
    
    function str=interpretLayers(this,view)
      str='rgb';
    end
    
    function im=getImage(this,k,view)
      assert(isa(k,'uint32'));
      assert(this.isLocked);
      im=imread([this.localCache,'/color',num2str(k,'%06d'),'.png']);
    end
    
    function flag=isFrameDynamic(this,view)
      flag=false;
    end
    
    function [p,q]=getFrame(this,k,view)
      assert(isa(k,'uint32'));
      assert(this.isLocked);
      p=[0;0;0];
      q=[1;0;0;0];
    end
        
    function flag=isProjectionDynamic(this,view)
      flag=false;
    end

    function pix=projection(this,ray,k,view)
      assert(this.isLocked);
      
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
          pix=[(u1+1)*((m-1)/2);
               (u2+1)*((n-1)/2)];
        otherwise
          error('unrecognized camera type');
      end   
      
    end
    
    function ray=inverseProjection(this,pix,k,view)
      assert(this.isLocked);
      
      switch(this.cameraType)
        case 2
          m=this.imsize(1);
          n=this.imsize(2);
          down=(pix(1,:)+1)*2/(n-1)+(m+1)/(1-n);
          right=(pix(2,:)+1)*(2/(n-1))+(1+n)/(1-n);
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
        otherwise
          error('unrecognized camera type');
      end      
    end
  end

end

