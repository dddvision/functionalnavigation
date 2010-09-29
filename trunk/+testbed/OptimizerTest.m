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
      
      dynamicModel=tom.DynamicModel.create(dynamicModelName,initialTime,uri);
      measure{1}=tom.Measure.create(measureName,initialTime,uri);
      
      fprintf('\ntom.Optimizer.create =');
      optimizer=tom.Optimizer.create(name);
      optimizer.defineProblem(dynamicModel,measure,true);
      assert(isa(optimizer,'tom.Optimizer'));
      fprintf(' ok');
    end
  end
  
end
