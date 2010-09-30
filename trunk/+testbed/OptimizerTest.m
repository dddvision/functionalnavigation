classdef OptimizerTest < handle
  
  methods (Access=public)
    function this=OptimizerTest(name,dynamicModelName,measureName,initialTime,uri)
      fprintf('\n\n*** Begin Optimizer Test ***\n');
            
      fprintf('\ndynamicModelName =');
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
      
      fprintf('\ntom.Optimizer.create =');
      optimizer=tom.Optimizer.create(name);
      assert(isa(optimizer,'tom.Optimizer'));
      fprintf(' ok');

      fprintf('\ndefineProblem =');
      dynamicModel=tom.DynamicModel.create(dynamicModelName,initialTime,uri);
      for k=2:optimizer.numInitialConditions()
        dynamicModel(k)=tom.DynamicModel.create(dynamicModelName,initialTime,uri);
      end
      measure{1}=tom.Measure.create(measureName,initialTime,uri);
      optimizer.defineProblem(dynamicModel,measure,true);
      fprintf(' ok');
      
      for index=uint32(0:2)
        fprintf('\n\nnumSolutions =');
        K=optimizer.numSolutions();
        assert(isa(K,'uint32'));
        fprintf(' %d',K);

        for k=uint32(0:(K-1))
          fprintf('\ngetSolution(%d) =',k);
          trajectory=optimizer.getSolution(k);
          assert(isa(trajectory,'tom.Trajectory'));
          fprintf(' ok');
        end
        
        for k=uint32(0:(K-1))
          fprintf('\ngetCost(%d) =',k);
          cost=optimizer.getCost(k);
          assert(isa(cost,'double'));
          fprintf(' %f',cost);
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
