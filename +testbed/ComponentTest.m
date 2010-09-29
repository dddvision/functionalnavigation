classdef ComponentTest
  
  methods (Access=public, Static=true)
    function this = ComponentTest(name,dynamicModelName,measureName,initialTime,uri)
      fprintf('\n\n*** Begin Component Test ***\n');  
  
      fprintf('\nname =');
      assert(isa(name,'char'));
      fprintf(' ''%s''',name);

      fprintf('\n\ntom.DynamicModel.isConnected = ')
      if(tom.DynamicModel.isConnected(name))
        fprintf('yes');
      else
        fprintf('no');
      end
      fprintf('\ntom.Measure.isConnected = ')
      if(tom.Measure.isConnected(name))
        fprintf('yes');
      else
        fprintf('no');
      end
      fprintf('\ntom.Optimizer.isConnected = ')
      if(tom.Optimizer.isConnected(name))
        fprintf('yes');
      else
        fprintf('no');
      end
      fprintf('\ntom.DataContainer.isConnected = ')
      if(tom.DataContainer.isConnected(name))
        fprintf('yes');
      else
        fprintf('no');
      end

      if(tom.DynamicModel.isConnected(name))
        testbed.DynamicModelTest(name,initialTime,uri);
      end
      if(tom.Measure.isConnected(name))
        testbed.MeasureTest(name,dynamicModelName,initialTime,uri);
      end
      if(tom.Optimizer.isConnected(name))
        testbed.OptimizerTest(name,dynamicModelName,measureName,initialTime,uri);
      end
      if(tom.DataContainer.isConnected(name))
        testbed.DataContainerTest(name,initialTime);
      end

      fprintf('\n\n*** End Component Test ***');
    end
  end
  
end
