classdef pendulum1 < trajectory
  properties
    a
    b
    damp
    omega
    data
    vbits
  end
  methods
    function this=pendulum1(v)
      if(nargin>0)
        % HACK: fixed domain makes this a limited type
        this.a=0;
        this.b=60;
        this.damp=0.1;
        this.omega=2;
        this.data=v;
        this.vbits=30;
      end
    end
  end
end
