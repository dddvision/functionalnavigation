function im=getImage(this,k)
  global cameraSim1_singleton
  if( (k<cameraSim1_singleton.a)||(k>cameraSim1_singleton.b) )
    im=zeros(0,0,3);
  else
    im=cameraSim1_singleton.ring{ktor(this,k)}.image;
  end
end
