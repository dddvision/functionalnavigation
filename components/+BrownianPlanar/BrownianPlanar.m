classdef BrownianPlanar < tom.DynamicModelBridge
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  methods (Access = public)
    function this = BrownianPlanar(initialTime, uri)
      this = this@tom.DynamicModelBridge('BrownianPlanar', initialTime, uri);
    end
  end
end
