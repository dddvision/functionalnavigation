classdef Default
  methods (Static = true, Access = public)
    function initialize(name)
      Default.XDynamics.initialize(name);
      Default.XMeasure.initialize(name);
      Default.LinearKalman.initialize(name);
    end
  end
end
