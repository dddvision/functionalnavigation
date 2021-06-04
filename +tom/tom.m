classdef tom
% Copyright 2011 Scientific Systems Company Inc., New BSD License
  methods (Static = true, Access = public)
    function initialize(name)
      tom.DynamicModelDefault.initialize(name);
      tom.MeasureDefault.initialize(name);
      tom.OptimizerDefault.initialize(name);
    end
  end
end
