% This class represents edges that determine the adjacency of nodes in a cost graph
classdef Edge
  properties (SetAccess=public,GetAccess=public)
    first % lower node index for this edge, uint32 scalar
    second  % upper node index for this edge, uint32 scalar
  end
  methods (Access=public)
    function this=Edge(A,B)
      if(nargin==1)
        N=numel(A);
        this=repmat(this,[1,N]);
        for n=1:N
          this(n).first=A(n).first;
          this(n).second=A(n).second;
        end
      elseif(nargin==2)
        N=numel(A);
        this=repmat(this,[1,N]);
        for n=1:N
          this(n).first=uint32(A(n));
          this(n).second=uint32(B(n));
        end
      end
    end
  end
end
