classdef ComponentTest
  
  methods (Access = public, Static = true)
    function this = ComponentTest(name, dynamicModelName, measureName, initialTime, uri)
      isDynamicModel = tom.DynamicModel.isConnected(name);
      isMeasure = tom.Measure.isConnected(name);
      isOptimizer = tom.Optimizer.isConnected(name);
      isDataContainer = tom.DataContainer.isConnected(name);

      if(isDynamicModel||isMeasure||isOptimizer||isDataContainer)
        fprintf('\n\n*** Begin Component Test ***\n');

        fprintf('\nname =');
        assert(isa(name, 'char'));
        fprintf(' ''%s''', name);

        fprintf('\nDynamicModel.isConnected = %d', isDynamicModel);
        fprintf('\nMeasure.isConnected = %d', isMeasure);
        fprintf('\nOptimizer.isConnected = %d', isOptimizer);
        fprintf('\nDataContainer.isConnected = %d', isDataContainer);

        if(isDynamicModel)
          testbed.DynamicModelTest(name, initialTime, uri);
        end
        if(isMeasure)
          testbed.MeasureTest(name, dynamicModelName, initialTime, uri);
        end
        if(isOptimizer)
          testbed.OptimizerTest(name, dynamicModelName, measureName, initialTime, uri);
        end
        if(isDataContainer)
          testbed.DataContainerTest(name, initialTime);
        end

        fprintf('\n\n*** End Component Test ***');
      else
        error('not connected');
      end
    end
  end
      
end