classdef OptimizerTest < handle
  
  methods (Access=public)
    function this=OptimizerTest(name,dynamicModelName,measureName,initialTime,uri)
      fprintf('\n\n*** OptimizerTest ***');
            
      fprintf('\n\ndynamicModelName =');
      assert(isa(dynamicModelName,'char'));
      fprintf(' ''%s''',dynamicModelName);

      fprintf('\nmeasureName =');
      assert(isa(measureName,'char'));
      fprintf(' ''%s''',measureName);
      
      fprintf('\ninitialTime =');
      assert(isa(initialTime,'tom.WorldTime')); 
      fprintf(' %f',double(initialTime));
      
      fprintf('\nuri =');
      assert(isa(uri,'char'));
      fprintf(' ''%s''',uri);
      
      fprintf('\n\ntom.Optimizer.description =');
      text=tom.Optimizer.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);
      
      dynamicModel=tom.DynamicModel.factory(dynamicModelName,initialTime,uri);
      measure{1}=tom.Measure.factory(measureName,uri);
      
      fprintf('\ntom.Optimizer.factory =');
      optimizer=tom.Optimizer.factory(name,dynamicModel,measure);
      assert(isa(optimizer,'tom.Optimizer'));
      fprintf(' ok');
    end
  end
  
end
