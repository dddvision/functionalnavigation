classdef tposquat < trajectory
  properties
    data
  end
  methods
    function this=tposquat(v)
      if(nargin>0)
        this.data=v;
      end
    end
  end
end
