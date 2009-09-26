function rho=getFocal(this,k)
  global cameraSim1_singleton
  if(numel(k)~=1)
    error('only scalar queries are supported');
  end
  rho=cameraSim1_singleton.ring{ktor(this,k)}.rho;
end
