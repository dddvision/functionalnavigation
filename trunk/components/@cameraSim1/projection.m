function xy=projection(this,k,ray)
  global cameraSim1_singleton
  buf=ktor(this,k);
  rho=cameraSim1_singleton.rho;
  m=cameraSim1_singleton.ring{buf}.size(1);
  n=cameraSim1_singleton.ring{buf}.size(2);
  a=rho/ray(1,:);
  u1=a.*ray(3,:);
  u2=a.*ray(2,:);
  xy=[(u2+1)*((n-1)/2);
      (u1+1)*((m-1)/2)];
end
