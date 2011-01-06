% Builds a tree of cache data indexed by pairs of indices
% This creates a single cache store shared among all instances
function data = computeIntermediateDataCache(this, na, nb)

  persistent cache

  nastr=['a', sprintf('%d', na)];
  nbstr=['b', sprintf('%d', nb)];

  if(isfield(cache,nastr)&&isfield(cache.(nastr), nbstr))
    data = cache.(nastr).(nbstr);
  else
    data = computeIntermediateData(this, na, nb);
    cache.(nastr).(nbstr) = data;
  end

end
