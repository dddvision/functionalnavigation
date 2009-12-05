classdef opticalFlowLK < opticalFlowLK.opticalFlowLKConfig & measure
  
  properties (SetAccess=private,GetAccess=private)
    sensor
    trajectory
  end
  
  methods (Access=public)
    function this=opticalFlowLK(u,x)
      this=this@measure(u,x);
      this.sensor=u;
      this.trajectory=x;
      fprintf('\n');
      fprintf('\nopticalFlowLK::opticalFlowLK');
    end
    
    function this=setTrajectory(this,x)
      this.trajectory=x;
    end
    
    function [a,b]=findEdges(this)
      fprintf('\n');
      fprintf('\nopticalFlowLK::findEdges');
      [aa,bb]=dataDomain(this.sensor);
      if( aa==bb )
        a=[];
        b=[];
      else
        a=aa;
        b=bb;
      end
    end
    
    function cost=computeEdgeCost(this,a,b)
      fprintf('\n');
      fprintf('\nopticalFlowLK::computeEdgeCost');
      
      [aa,bb]=dataDomain(this.sensor);
      assert((b>a)&&(a>=aa)&&(b<=bb));
      
      ta=getTime(this.sensor,a);
      tb=getTime(this.sensor,b);
      [pa,qa]=evaluate(this.trajectory,ta);
      fprintf('\nx(%f) = < ',ta);
      fprintf('%f ',[pa;qa]);
      fprintf('>');
      [pb,qb]=evaluate(this.trajectory,tb);      
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
      
      [u,v]=lucasKanade(this,im1,im2);
      
      Ea=quat2EulerDD(qa);
      Eb=quat2EulerDD(qb);
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
    
    % lucas kanade algorithm, without pyramids (only 1 level)
    function [u,v]=lucasKanade(this,im1,im2)
      [fx,fy,ft]=computeDerivatives(im1,im2);
      u=zeros(size(im1));
      v=zeros(size(im2));
      halfWindow=floor(this.windowSize/2);
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
        end
      end
      u(isnan(u))=0;
      v(isnan(v))=0;
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

function cost=computeCost(Vx_OF,Vy_OF,uvr,uvt)
  [FIELD_Y,FIELD_X]=size(Vx_OF);
  upperBound=(FIELD_X.*FIELD_Y.*2);
  Vxr(:,:)=uvr(1,:,:);
  Vyr(:,:)=uvr(2,:,:);
  Vxt(:,:)=uvt(1,:,:);
  Vyt(:,:)=uvt(2,:,:);
  % Drop magnitude of translation
  mag=sqrt(Vxt.*Vxt + Vyt.*Vyt);
  mag(mag(:)==0)=1; 
  Vxt=Vxt./mag;
  Vyt=Vyt./mag;
  % remove rotation effect
  Vx_OFT=(Vx_OF - Vxr);
  Vy_OFT=(Vy_OF - Vyr);
  % Drop magnitude and keep direction only
  mag=sqrt(Vx_OFT.*Vx_OFT + Vy_OFT.*Vy_OFT);
  mag(mag(:)==0)=1; 
  Vx_OFTD=Vx_OFT./mag;
  Vy_OFTD=Vy_OFT./mag;
  % remove NaNs
  Vx_OFTD(isnan(Vx_OFTD))=0;
  Vy_OFTD(isnan(Vy_OFTD))=0;
  % Calculate Error
  ErrorX=(Vx_OFTD - Vxt);
  ErrorY=(Vy_OFTD - Vyt);
  ErrorMag=sqrt(ErrorX.*ErrorX + ErrorY.*ErrorY);
  cost=sum(ErrorMag(:))/upperBound; % TODO: check this calculation
end

% compute horizontal, vertical and time derivative
function [fx,fy,ft] = computeDerivatives(im1,im2)
  if( (size(im1,1)~=size(im2,1))||(size(im1,2)~=size(im2,2)) )
    error('input images are not the same size');
  end
  if( (size(im1,3)~=1)||(size(im2,3)~=1) )
    error('method only works for gray-level images');
  end
  fx=conv2(double(im1),double(0.25* [-1 1; -1 1])) + conv2(double(im2), double(0.25*[-1 1; -1 1]));
  fy=conv2(double(im1), double(0.25*[-1 -1; 1 1])) + conv2(double(im2), double(0.25*[-1 -1; 1 1]));
  ft=conv2(double(im1), double(0.25*ones(2))) + conv2(double(im2), double(-0.25*ones(2)));
  % make same size as input
  fx=fx(1:size(fx,1)-1, 1:size(fx,2)-1);
  fy=fy(1:size(fy,1)-1, 1:size(fy,2)-1);
  ft=ft(1:size(ft,1)-1, 1:size(ft,2)-1);
end

function E=quat2EulerDD(Q)
  N=size(Q,2);
  Q=quatNormDD(Q);
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
	
function Q=quatNormDD(Q)
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
