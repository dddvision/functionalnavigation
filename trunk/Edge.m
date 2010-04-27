% This class represents edges that determine the adjacency of nodes in a cost graph
classdef Edge
  properties (SetAccess=public,GetAccess=public)
    first % lower node index for this edge, uint32 scalar
    second  % upper node index for this edge, uint32 scalar
  end
  methods (Access=public)
    function this=Edge(first,second)
      if(nargin==2)
        this.first=uint32(first);
        this.second=uint32(second);
      end
    end
  end
end
