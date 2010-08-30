classdef GraphEdge
  
  properties (SetAccess=public,GetAccess=public)
    first=uint32(0);
    second=uint32(0);
  end
  
  methods (Access=public)
    function this=GraphEdge(A,B)
      if(nargin==1)
        assert(isa(A(1).first,'uint32'));
        N=numel(A);
        if(N==1)
          this.first=A.first;
          this.second=A.second;
        else
          this(1,N)=this;
          for n=1:N
            this(n).first=A(n).first;
            this(n).second=A(n).second;
          end
        end
      elseif(nargin==2)
        assert(isa(A,'uint32'));
        assert(isa(B,'uint32'));
        N=numel(A);
        if(N==1)
          this.first=A;
          this.second=B;
        else
          this(1,N)=this;
          for n=1:N
            this(n).first=A(n);
            this(n).second=B(n);
          end
        end
      end
    end
    
    function display(this)
      for n=1:numel(this)
        fprintf('\n%s = [%d,%d]\n',inputname(1),this(n).first,this(n).second);
      end
    end
  end
  
end
