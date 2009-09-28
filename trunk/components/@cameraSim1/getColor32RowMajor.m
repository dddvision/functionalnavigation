function rgb=getColor32RowMajor(this,k)
  global cameraSim1_singleton
  if( (k<cameraSim1_singleton.a)||(k>cameraSim1_singleton.b) )
    rgb=zeros(0,0,3);
  else
    rgb=cameraSim1_singleton.ring{ktor(this,k)}.image;
  end
end
