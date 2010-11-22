 function cost=computeCost(this,Vx_OF,Vy_OF,uvr,uvt)
 
 %TODO: Modify to use model
 
  % Seperate flow components
  Vxr=uvr(1,:);
  Vyr=uvr(2,:);
  Vxt=uvt(1,:);
  Vyt=uvt(2,:);

  % Remove rotation effect
  Vx_OFT=(Vx_OF-Vxr);
  Vy_OFT=(Vy_OF-Vyr);
  
  % Drop magnitude of translation
  mag=sqrt(Vxt.*Vxt+Vyt.*Vyt);
  mag(mag(:)<eps)=1; 
  Vxt=Vxt./mag;
  Vyt=Vyt./mag;
  
  % Drop magnitude of translation
  mag=sqrt(Vx_OFT.*Vx_OFT+Vy_OFT.*Vy_OFT);
  mag(mag(:)<eps)=1; 
  Vx_OFTD=Vx_OFT./mag;
  Vy_OFTD=Vy_OFT./mag;
  
  % remove NaNs
  Vx_OFTD(isnan(Vx_OFTD))=0;
  Vy_OFTD(isnan(Vy_OFTD))=0;
  
  % Euclidean distance
  ErrorX=(Vx_OFTD-Vxt);
  ErrorY=(Vy_OFTD-Vyt);
  ErrorMag=sqrt(ErrorX.*ErrorX+ErrorY.*ErrorY);
  upperBound=2*numel(Vx_OF);

  % Absolute angular distance
%   ErrorMag=abs(acos(Vx_OFTD.*Vxt+Vy_OFTD.*Vyt));
%   upperBound=pi*numel(Vx_OF);
  
  cost=sum(ErrorMag(:))*(this.maxCost/upperBound);
 end
 