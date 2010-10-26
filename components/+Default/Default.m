classdef Default
  methods (Static = true, Access = public)
    function initialize(name)
      Default.DefaultDataContainer.initialize(name);
      Default.DefaultDynamicModel.initialize(name);
      Default.DefaultMeasure.initialize(name);
      Default.DefaultOptimizer.initialize(name);
    end
  end
end
