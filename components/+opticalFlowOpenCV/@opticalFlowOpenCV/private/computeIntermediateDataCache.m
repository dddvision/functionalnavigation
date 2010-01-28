% Builds a tree of cache data indexed by pairs of indices
% This creates a single cache store shared among all instances
function data=computeIntermediateDataCache(this,ka,kb)

  persistent cache

  kastr=['a',sprintf('%d',ka)];
  kbstr=['b',sprintf('%d',kb)];

  if( isfield(cache,kastr) && isfield(cache.(kastr),kbstr) )
    data=cache.(kastr).(kbstr);
  else
    data=computeIntermediateData(this,ka,kb);
    cache.(kastr).(kbstr)=data;
  end

end
