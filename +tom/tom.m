classdef tom
  methods (Static = true, Access = public)
    function initialize(name)
      tom.DynamicModelDefault.initialize(name);
      tom.MeasureDefault.initialize(name);
      tom.OptimizerDefault.initialize(name);
    end
  end
end
