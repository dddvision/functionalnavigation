classdef opticalFlowLK < measure
  
  properties (GetAccess=private,SetAccess=private)
    cameraHandle
    windowSize
  end  
  
  methods (Access=public)
    function this=opticalFlowLK(cameraHandle)
      fprintf('\n');
      fprintf('\nopticalFlowLK::opticalFlowLK');
      this.cameraHandle=cameraHandle;
      this.windowSize=3; 
    end
    
    function cost=evaluate(this,x,tmin)
      fprintf('\n');
      fprintf('\nopticalFlowLK::evaluate');
      [a,b]=domain(this.cameraHandle);
      tmin=getTime(this.cameraHandle,a);
      tmax=getTime(this.cameraHandle,b);
      pqa=evaluate(x,tmin);
      fprintf('\nx(%f) = < ',tmin);
      fprintf('%f ',pqa);
      fprintf('>');
      pqb=evaluate(x,tmax);      
      fprintf('\nx(%f) = < ',tmax);
      fprintf('%f ',pqb);
      fprintf('>');
      im1=getImage(this.cameraHandle,a); 
	  im2=getImage(this.cameraHandle,b); 
	  if(interpretLayers(this.cameraHandle)=='rgb')
	    im1=rgb2gray(im1); 
	    im2=rgb2gray(im2); 
	  end
	  [u,v]=lucasKanade(this,im1,im2);  
	  pa=pqa(1:3,:);
	  qa=pqa(4:7,:);
	  pb=pqb(1:3,:);
	  qb=pqb(4:7,:);
 	  Ea=quat2EulerDD(this,qa);
	  Eb=quat2EulerDD(this,qb);
	  translation(1)=pb(1)-pa(1);
	  translation(2)=pb(2)-pa(2);
	  translation(3)=pb(3)-pa(3);
	  rotation(1)=Eb(1)-Ea(1);
	  rotation(2)=Eb(2)-Ea(2);
	  rotation(3)=Eb(3)-Ea(3);
	  [uvr, uvt]=generateFlow(this,translation,rotation);
	  cost=computeCost(this,u,v,uvr, uvt);
	  fprintf('\ncost = %f',cost);

    end
  end
  
  methods (Access=private)
    
    function [u,v]=lucasKanade(x, im1, im2)

        %LucasKanade  lucas kanade algorithm, without pyramids (only 1 level);
		[fx, fy, ft]=computeDerivatives(x, im1, im2);
		u=zeros(size(im1));
		v=zeros(size(im2));
		halfWindow=floor(x.windowSize/2);
		for i=halfWindow+1:size(fx,1)-halfWindow
		for j=halfWindow+1:size(fx,2)-halfWindow
		  curFx=fx(i-halfWindow:i+halfWindow, j-halfWindow:j+halfWindow);
		  curFy=fy(i-halfWindow:i+halfWindow, j-halfWindow:j+halfWindow);
		  curFt=ft(i-halfWindow:i+halfWindow, j-halfWindow:j+halfWindow);
		  curFx=curFx';
		  curFy=curFy';
		  curFt=curFt';
		  curFx=curFx(:);
		  curFy=curFy(:);
		  curFt=-curFt(:);
		  A=[curFx curFy];
		  U=pinv(A'*A)*A'*curFt;
		  u(i,j)=U(1);
		  v(i,j)=U(2);
		end;
		end;
		u(isnan(u))=0;
		v(isnan(v))=0;
    end 
		
	function [fx, fy, ft]=computeDerivatives(x, im1, im2);
		
        %ComputeDerivatives	Compute horizontal, vertical and time derivative
		if (size(im1,1)~=size(im2,1)) | (size(im1,2)~=size(im2,2))
		error('input images are not the same size');
		end;
		if (size(im1,3)~=1) | (size(im2,3)~=1)
		error('method only works for gray-level images');
		end;
		fx=conv2(double(im1),double(0.25* [-1 1; -1 1])) + conv2(double(im2), double(0.25*[-1 1; -1 1]));
		fy=conv2(double(im1), double(0.25*[-1 -1; 1 1])) + conv2(double(im2), double(0.25*[-1 -1; 1 1]));
		ft=conv2(double(im1), double(0.25*ones(2))) + conv2(double(im2), double(-0.25*ones(2)));
		% make same size as input
		fx=fx(1:size(fx,1)-1, 1:size(fx,2)-1);
		fy=fy(1:size(fy,1)-1, 1:size(fy,2)-1);
		ft=ft(1:size(ft,1)-1, 1:size(ft,2)-1);
	end

	function [uvr, uvt] = generateFlow(x,translation,rotation)
		
		s1=sin(rotation(1));
		c1=cos(rotation(1));
		s2=sin(rotation(2));
		c2=cos(rotation(2));
		s3=sin(rotation(3));
		c3=cos(rotation(3));
		R=[c3*c2, c3*s2*s1-s3*c1, s3*s1+c3*s2*c1; s3*c2, c3*c1+s3*s2*s1, s3*s2*c1-c3*s1; -s2, c2*s1, c2*c1];
		[m,n]=getImageSize(x.cameraHandle);
		[jj,ii]=meshgrid((1:m)-1,(1:n)-1);
		pix=[jj(:)';ii(:)'];
		ray=inverseProjection(x.cameraHandle,pix);
		ray_new=transpose(R)*ray; 
		x_new=projection(x.cameraHandle,ray_new);
		fr(1,:)=pix(1,:)-x_new(1,:);
		fr(2,:)=pix(2,:)-x_new(2,:);
		T_norm=(1E-8)*translation/sqrt(dot(translation,translation));
		ray_new(1,:)=ray(1,:)-T_norm(3);
		ray_new(2,:)=ray(2,:)-T_norm(1);
		ray_new(3,:)=ray(3,:)-T_norm(2);
		x_new=projection(x.cameraHandle,ray_new);
		ft(1,:)=pix(1,:)-x_new(1,:);
		ft(2,:)=pix(2,:)-x_new(2,:);
		uvr(1,:,:)=reshape(fr(1,:),m,n);
		uvr(2,:,:)=reshape(fr(2,:),m,n);
		uvt(1,:,:)=reshape(ft(1,:),m,n);
		uvt(2,:,:)=reshape(ft(2,:),m,n);
		uvr(isnan(uvr(:,:,:))) = 0;
		uvt(isnan(uvt(:,:,:))) = 0;
	end

	function cost = computeCost(x, Vx_OF,Vy_OF,uvr,uvt)
			
			[FIELD_Y,FIELD_X]=size(Vx_OF);
			upperBound=(FIELD_X.*FIELD_Y.*2);
			Vxr(:,:)=uvr(1,:,:);
			Vyr(:,:)=uvr(2,:,:);
			Vxt(:,:)=uvt(1,:,:);
			Vyt(:,:)=uvt(2,:,:);
		    % Drop magnitude of translation
		    mag=(Vxt.^2 + Vyt.^2).^.5; % TODO: use faster magnitude calculation
		 	mag(mag(:)==0)=1; 
	        Vxt=Vxt./mag;
	        Vyt=Vyt./mag;
		    % remove rotation effect
		    Vx_OFT=(Vx_OF - Vxr);
		    Vy_OFT=(Vy_OF - Vyr);
		    % Drop magnitude and keep direction only
		    mag=(Vx_OFT.^2 + Vy_OFT.^2).^.5;
		    mag(mag(:)==0)=1; 
		    Vx_OFTD=Vx_OFT./mag;
		    Vy_OFTD=Vy_OFT./mag;
		    % remove NaNs
		    Vx_OFTD(isnan(Vx_OFTD))=0;
		    Vy_OFTD(isnan(Vy_OFTD))=0;
		    % Calculate Error
		    ErrorX=(Vx_OFTD - Vxt);
		    ErrorY=(Vy_OFTD - Vyt);
		    ErrorMag=(ErrorX.^2 + ErrorY.^2).^.5;
		    cost=sum(ErrorMag(:))/upperBound; % TODO: check this calculation
	end

	function E=quat2EulerDD(x,Q)
		
		N=size(Q,2);
		Q=quatNormDD(x,Q);
		q1=Q(1,:);
		q2=Q(2,:);
		q3=Q(3,:);
		q4=Q(4,:);
		q11=q1.*q1;
		q22=q2.*q2;
		q33=q3.*q3;
		q44=q4.*q4;
		q12=q1.*q2;
		q23=q2.*q3;
		q34=q3.*q4;
		q14=q1.*q4;
		q13=q1.*q3;
		q24=q2.*q4;
		if isnumeric(Q)
		  E=zeros(3,N);
		  E(1,:)=atan2(2*(q34+q12),q11-q22-q33+q44);
		  E(2,:)=real(asin(-2*(q24-q13)));
		  E(3,:)=atan2(2*(q23+q14),q11+q22-q33-q44);
		else
		  E=sym(zeros(3,N));
		  E(1,:)=atan((2*(q34+q12))./(q11-q22-q33+q44));
		  E(2,:)=asin(-2*(q24-q13));
		  E(3,:)=atan((2*(q23+q14))./(q11+q22-q33-q44));
		end
	end
	
	function Q=quatNormDD(x,Q)
		  % input checking
		  if(size(Q,1)~=4)
		    error('argument must be 4-by-n');
		  end
		  % extract elements
		  q1=Q(1,:);
		  q2=Q(2,:);
		  q3=Q(3,:);
		  q4=Q(4,:);
		  % normalization factor
		  n=sqrt(q1.*q1+q2.*q2+q3.*q3+q4.*q4);
		  % handle negative first element and zero denominator
		  s=sign(q1);
		  ns=n.*s;
		  ns(ns==0)=1;
		  % normalize
		  Q(1,:)=q1./ns;
		  Q(2,:)=q2./ns;
		  Q(3,:)=q3./ns;
		  Q(4,:)=q4./ns;
	end

  end
 
end
