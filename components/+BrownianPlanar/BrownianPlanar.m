classdef BrownianPlanar < tom.DynamicModelBridge
  methods (Access=public)
    function this=BrownianPlanar(initialTime,uri)
      this=this@tom.DynamicModelBridge('BrownianPlanar',initialTime,uri);
    end
  end
end
