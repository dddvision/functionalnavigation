classdef ShipDynamics < tom.DynamicModelBridge
  methods (Access = public)
    function this = ShipDynamics(initialTime, uri)
      this = this@tom.DynamicModelBridge('ShipDynamics', initialTime, uri);
    end
  end
end
