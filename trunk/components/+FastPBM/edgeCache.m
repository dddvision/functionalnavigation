% Caches data indexed by pairs of indices
function data = edgeCache(nA, nB, obj)
  persistent cache
  nAKey = ['a', sprintf('%d', nA)];
  nBKey = ['b', sprintf('%d', nB)];
  if( isfield(cache, nAKey)&&isfield(cache.(nAKey), nBKey) )
    data = cache.(nAKey).(nBKey);
  else
    data = obj.processEdge(nA, nB);
    cache.(nAKey).(nBKey) = data;
  end
end
