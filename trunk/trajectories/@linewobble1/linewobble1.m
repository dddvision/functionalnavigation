classdef linewobble1 < trajectory
  properties
    a
    b
    data
    vbits
  end
  methods
    function this=linewobble1(v)
      if(nargin>0)
        % HACK: fixed domain makes this a limited type
        this.a=0;
        this.b=60;
        this.data=v;
        this.vbits=30;
      end
    end
  end
end
