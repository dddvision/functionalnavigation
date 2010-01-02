classdef opticalFlowOpenCV < opticalFlowOpenCV.opticalFlowOpenCVConfig & measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    diagonal
    ready
  end
  
  methods (Access=public)
    function this=opticalFlowOpenCV(uri)
      this=this@measure(uri);
      fprintf('\n');
      fprintf('\nopticalFlowOpenCV::opticalFlowOpenCV');
      
      cvlib_mex=this.cvlib_mex;
      repository=this.repository;
      cvlib_mexAgreeToLicense=this.cvlib_mexAgreeToLicense;
      localDir=fileparts(mfilename('fullpath'));
      localDir=[localDir '\private'];
      localCache=fullfile(localDir,cvlib_mex);
      
      if(~exist(localCache,'dir'))
        fprintf('\n%s%s.zip',repository,cvlib_mex);
        user_input=input('\nDo you agree to the license associated with the above URL (Y/N)? ','s');
        if(user_input=='Y'||user_input=='y')
        	cvlib_mexAgreeToLicense=true;
        end
        if(cvlib_mexAgreeToLicense)
 			mkdir(localDir,cvlib_mex);     
        	zipName=[cvlib_mex,'.zip'];
       		localZip=[localDir,'\',zipName];
        	url=[repository,zipName];
        	fprintf('\ncaching: %s',url);
        	urlwrite(url,localZip);
        	fprintf('\nunzipping: %s',localZip);
        	unzip(localZip,localDir);
        	delete(localZip);          
        end
      end
	                     
      this.ready=false;
      [scheme,resource]=strtok(uri,':');
      switch(scheme)
      case 'matlab'
        container=eval(resource(2:end));
        list=listSensors(container,'camera');
        if(~isempty(list))
          this.sensor=getSensor(container,list(1));
          this.diagonal=false;
          this.ready=true;
        end
      end                  
    end
    
    function time=getTime(this,k)
      assert(this.ready);
      time=getTime(this.sensor,k);
    end
    
    function status=refresh(this)
      assert(this.ready);
      status=refresh(this.sensor);
    end
    
    function flag=isDiagonal(this)
      flag=this.diagonal;
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\npointBasedMeasure::findEdges');
      a=[];
      b=[];      
      if(this.ready)
        ka=first(this.sensor);
        kb=last(this.sensor);
        if(kb>=ka)
          a=ka;
          b=kb;
        end
      end
    end
    
    function cost=computeEdgeCost(this,x,a,b)
      fprintf('\n');
      fprintf('\npointBasedMeasure::computeEdgeCost');
      assert(this.ready);
      
      ka=first(this.sensor);
      kb=last(this.sensor);
      assert((b>a)&&(a>=ka)&&(b<=kb));
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      [pa,qa]=evaluate(x,ta);
      fprintf('\nx(%f) = < ',ta);
      fprintf('%f ',[pa;qa]);
      fprintf('>');
      [pb,qb]=evaluate(x,tb);      
      fprintf('\nx(%f) = < ',tb);
      fprintf('%f ',[pb;qb]);
      fprintf('>');
      
      im1=getImage(this.sensor,a); 
      im2=getImage(this.sensor,b); 
      if( strcmp(interpretLayers(this.sensor),'rgb') )
        im1=rgb2gray(im1); 
        im2=rgb2gray(im2); 
      end
      imsize=size(im1);
            
      Ea=Quat2Euler(qa);
      Eb=Quat2Euler(qb);
      
      cor_in=cvlib_mex('goodfeatures',im1);
      cor_out=cvlib_mex('opticalFlowPyrLK',im1,im2,cor_in,10);
      x=cor_in(:,1);
	  y=cor_in(:,2);
      u=cor_in(:,1)-cor_out(:,1);
	  v=cor_in(:,2)-cor_out(:,2);
      
	  translation(1)=pb(1)-pa(1);
      translation(2)=pb(2)-pa(2);
      translation(3)=pb(3)-pa(3);
      rotation(1)=Eb(1)-Ea(1);
      rotation(2)=Eb(2)-Ea(2);
      rotation(3)=Eb(3)-Ea(3);
      [uvr,uvt]=generateFlow(this,translation,rotation,imsize);
      
      cost=computeCost(u,v,uvr,uvt);
      fprintf('\ncost = %f',cost);      
  end  
  
  function [uvr,uvt]=generateFlow(this,translation,rotation,imsize)
      s1=sin(rotation(1));
      c1=cos(rotation(1));
      s2=sin(rotation(2));
      c2=cos(rotation(2));
      s3=sin(rotation(3));
      c3=cos(rotation(3));
      R=[c3*c2, c3*s2*s1-s3*c1, s3*s1+c3*s2*c1; s3*c2, c3*c1+s3*s2*s1, s3*s2*c1-c3*s1; -s2, c2*s1, c2*c1];
      m=imsize(1);
      n=imsize(2);
      [ii,jj]=ndgrid((1:m)-1,(1:n)-1);
      pix=[jj(:)';ii(:)'];
      ray=inverseProjection(this.sensor,pix);
      ray_new=transpose(R)*ray; 
      x_new=projection(this.sensor,ray_new);
      fr(1,:)=pix(1,:)-x_new(1,:);
      fr(2,:)=pix(2,:)-x_new(2,:);
      T_norm=(1E-8)*translation/sqrt(dot(translation,translation));
      ray_new(1,:)=ray(1,:)-T_norm(3);
      ray_new(2,:)=ray(2,:)-T_norm(1);
      ray_new(3,:)=ray(3,:)-T_norm(2);
      x_new=projection(this.sensor,ray_new);
      ft(1,:)=pix(1,:)-x_new(1,:);
      ft(2,:)=pix(2,:)-x_new(2,:);
      uvr(1,:,:)=reshape(fr(1,:),m,n);
      uvr(2,:,:)=reshape(fr(2,:),m,n);
      uvt(1,:,:)=reshape(ft(1,:),m,n);
      uvt(2,:,:)=reshape(ft(2,:),m,n);
      uvr(isnan(uvr(:,:,:))) = 0;
      uvt(isnan(uvt(:,:,:))) = 0;
  end
  
end
end