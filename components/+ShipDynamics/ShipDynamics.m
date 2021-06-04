classdef ShipDynamics < tom.DynamicModelBridge
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  methods (Access = public)
    function this = ShipDynamics(initialTime, uri)
      this = this@tom.DynamicModelBridge('ShipDynamics', initialTime, uri);
    end
  end
end
