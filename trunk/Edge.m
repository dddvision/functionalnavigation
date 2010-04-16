classdef Edge
  properties (SetAccess=public,GetAccess=public)
    first=uint32(0);
    second=uint32(0);
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
