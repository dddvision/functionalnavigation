function im=getImage(this,k,view)
  global cameraSim1_singleton
  assert(isa(k,'uint32'));
  assert(isa(view,'uint32'));
  assert(view==0);
  assert(k>=cameraSim1_singleton.a);
  assert(k<=cameraSim1_singleton.b);
  im=cameraSim1_singleton.ring{ktor(this,k)}.image;
end
