classdef OptimizerTest < handle
  
  methods (Access=public)
    function this=OptimizerTest(name,dynamicModel,measure)
      fprintf('\n\nOptimizer.description =');
      text=Optimizer.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);
      
      fprintf('\nOptimizer.factory =');
      optimizer=Optimizer.factory(name,dynamicModel,measure);
      assert(isa(optimizer,'Optimizer'));
      fprintf(' ok');
    end
  end
  
end
