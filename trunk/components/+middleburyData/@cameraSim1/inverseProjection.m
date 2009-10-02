function ray=inverseProjection(this,k,view,xy)
  global cameraSim1_singleton
  buf=ktor(this,k);
  rho=cameraSim1_singleton.rho;
  m=cameraSim1_singleton.ring{buf}.size(1);
  n=cameraSim1_singleton.ring{buf}.size(2);
  u1=xy(2,:)*(2/(m-1))-1;
  u2=xy(1,:)*(2/(n-1))-1;
  den=sqrt(u1.*u1+u2.*u2+rho*rho);
  ray=[rho./den;u2./den;u1./den];
end
