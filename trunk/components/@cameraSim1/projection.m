function xy=projection(this,k,ray)
  global cameraSim1_singleton
  buf=ktor(this,k);
  rho=cameraSim1_singleton.ring{buf}.rho;
  m=cameraSim1_singleton.ring{buf}.size(1);
  n=cameraSim1_singleton.ring{buf}.size(2);
  u=rho/ray(1)*[ray(3);ray(2)];
  xy=[(u(2)+1)*((n-1)/2);
      (u(1)+1)*((m-1)/2)];
end
