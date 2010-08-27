classdef BrownianPlanar < DynamicModelBridge
  methods (Access=public)
    function this=BrownianPlanar(initialTime,uri)
      this=this@DynamicModelBridge('BrownianPlanar',initialTime,uri);
    end
  end
end
