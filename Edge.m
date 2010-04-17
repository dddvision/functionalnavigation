% This class represents edges that determine the adjacency of nodes in a cost graph
classdef Edge
  properties (SetAccess=public,GetAccess=public)
    first=uint32(0);
    second=uint32(0);
  end
  methods (Access=public)
    function this=Edge(first,second)
      if(nargin==2)
        this.first=uint32(first); % lower node index for this edge, uint32 scalar
        this.second=uint32(second); % upper node index for this edge, uint32 scalar
      end
    end
  end
end
