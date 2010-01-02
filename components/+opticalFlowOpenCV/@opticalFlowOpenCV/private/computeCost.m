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