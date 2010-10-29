classdef OptimizerTest < handle
  
  methods (Access = public)
    function this = OptimizerTest(name, dynamicModelName, measureName, initialTime, uri)
      fprintf('\n\n*** Begin Optimizer Test ***\n');
            
      fprintf('\ndynamicModelName =');
      assert(isa(dynamicModelName, 'char'));
      fprintf(' ''%s''', dynamicModelName);
      
      fprintf('\nmeasureName = {');
      assert(isa(measureName, 'cell'));
      K = numel(measureName);
      for k = 1:K
        assert(isa(measureName{k}, 'char'));
        if(k>1)
          fprintf(', ');
        end
        fprintf('''%s''', measureName{k});
      end
      fprintf('}');
      
      fprintf('\ninitialTime =');
      assert(isa(initialTime, 'tom.WorldTime')); 
      fprintf(' %f', double(initialTime));
      
      fprintf('\nuri =');
      assert(isa(uri, 'char'));
      fprintf(' ''%s''', uri);
      
      fprintf('\n\ntom.Optimizer.description(''%s'') =', name);
      text = tom.Optimizer.description(name);
      assert(isa(text, 'char'));
      fprintf(' %s', text);
      
      fprintf('\ntom.Optimizer.create(''%s'') =', name);
      optimizer = tom.Optimizer.create(name);
      assert(isa(optimizer, 'tom.Optimizer'));
      fprintf(' ok');

      
      measure = cell(numel(measureName),1);
      for k = 1:K
        fprintf('\ntom.Measure.create(''%s'') =', measureName{k});
        measure{k} = tom.Measure.create(measureName{k}, initialTime, uri);
        fprintf(' ok');
      end
      
      fprintf('\ndefineProblem =');
      dynamicModel = tom.DynamicModel.create(dynamicModelName, initialTime, uri);
      for k = 2:optimizer.numInitialConditions()
        dynamicModel(k) = tom.DynamicModel.create(dynamicModelName, initialTime, uri);
      end
      optimizer.defineProblem(dynamicModel, measure, true);
      fprintf(' ok');
      
      for index = uint32(0:2)
        fprintf('\n\nnumSolutions =');
        K = optimizer.numSolutions();
        assert(isa(K, 'uint32'));
        fprintf(' %d', K);

        for k = uint32(1):K
          fprintf('\ngetSolution(%d) =', k-uint32(1));
          trajectory = optimizer.getSolution(k-uint32(1));
          assert(isa(trajectory, 'tom.Trajectory'));
          fprintf(' ok');
        end
        
        for k = uint32(1):K
          fprintf('\ngetCost(%d) =', k-uint32(1));
          cost = optimizer.getCost(k-uint32(1));
          assert(isa(cost, 'double'));
          fprintf(' %f', cost);
        end

        fprintf('\n\nrefreshProblem =');
        optimizer.refreshProblem();
        fprintf(' ok');

        fprintf('\nstep =');
        optimizer.step();
        fprintf(' ok');
      end
      
      fprintf('\n\n*** End Optimizer Test ***');
    end
  end
  
end
