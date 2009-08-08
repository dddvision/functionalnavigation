classdef optimizer
  properties
  end  
  methods (Access=protected)
    function this=optimizer
    end
    function delete(this)
    end
  end
  methods (Access=public,Abstract=true)
    [this,v,w]=init(this,H);
    [this,H,v,w]=step(this,H,v,w);
  end
end
