function r=ktor(this,k)
  global cameraSim1_singleton
  r=mod(cameraSim1_singleton.base+k-cameraSim1_singleton.a-1,cameraSim1_singleton.ringsz)+1;
end
