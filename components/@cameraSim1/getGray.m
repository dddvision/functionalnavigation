function gray=getGray(this,k)
  global cameraSim1_singleton
  if( (k<cameraSim1_singleton.a)||(k>cameraSim1_singleton.b) )
    gray=NaN;
  else
    gray=cameraSim1_singleton.ring{ktor(this,k)}.gray;
  end
end
