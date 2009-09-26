function time=getTime(this,k)
  global cameraSim1_singleton
  if(numel(k)~=1)
    error('only scalar queries are supported');
  end
  time=cameraSim1_singleton.ring{ktor(this,k)}.time;
end
