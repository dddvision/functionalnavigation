% Caches data indexed by individual indices
% Copyright 2011 Scientific Systems Company Inc., New BSD License
function data = nodeCache(n, obj)
  persistent cache
  nKey = ['n', sprintf('%d', n)];
  if( isfield(cache, nKey) )
    data = cache.(nKey);
  else
    data = obj.processNode(n);
    cache.(nKey) = data;
  end
end
