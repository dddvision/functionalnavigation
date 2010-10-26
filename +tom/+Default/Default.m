classdef Default
  methods (Static = true, Access = public)
    function initialize(name)
      tom.Default.DataContainer.initialize(name);
      tom.Default.DynamicModel.initialize(name);
      tom.Default.Measure.initialize(name);
      tom.Default.Optimizer.initialize(name);
    end
  end
end
