classdef OptimizerTest < handle
  
  methods (Access=public)
    function this=OptimizerTest(name,dynamicModel,measure)
      fprintf('\n\ntom.Optimizer.description =');
      text=tom.Optimizer.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);
      
      fprintf('\ntom.Optimizer.factory =');
      optimizer=tom.Optimizer.factory(name,dynamicModel,measure);
      assert(isa(optimizer,'tom.Optimizer'));
      fprintf(' ok');
    end
  end
  
end
