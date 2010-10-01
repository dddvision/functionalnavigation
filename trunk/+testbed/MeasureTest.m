classdef MeasureTest < handle
  
  methods (Access=public)
    function this=MeasureTest(name,dynamicModelName,initialTime,uri)
      fprintf('\n\n*** Begin Measure Test ***\n');
      
      fprintf('\ninitialTime =');
      assert(isa(initialTime,'tom.WorldTime'));
      fprintf(' %f',double(initialTime));
      
      fprintf('\nuri =');
      assert(isa(uri,'char'));
      fprintf(' ''%s''',uri);
      
      fprintf('\ntom.Measure.description =');
      text=tom.Measure.description(name);
      assert(isa(text,'char'));
      fprintf(' %s',text);
      
      fprintf('\ntom.Measure.create =');
      measure=tom.Measure.create(name,initialTime,uri);
      assert(isa(measure,'tom.Measure'));
      fprintf(' ok');
      
      testbed.SensorTest(measure);

      dynamicModel=tom.DynamicModel.create(dynamicModelName,initialTime,uri);
      
      % HACK: evaluate evaluate all edges, refresh, repeat
      if(measure.hasData())
        for k=1:3
          first=measure.first();
          last=measure.last();
          edges=measure.findEdges(dynamicModel,first,last,first,last);
          for edgeIndex=1:numel(edges)
            cost=measure.computeEdgeCost(dynamicModel,edges(edgeIndex));
          end
          measure.refresh();
        end
      end
      
      % Call all interface functions
      % Check exception handling
      
      % For each edge that the measure supports for the specified data set
        % Compute bias? (distance from ground truth to cost minimum)
        % Perturb trajectory small amounts around ground truth and evaluate costs
        % Include tests with ta=tb and ta~=tb
        % Granularity (dilution of precision, distance until cost increases at all)
        % Monotonicity (distance until cost begins to decrease)
        % Cost (maybe smoothed around ground truth)
        % Jacobian (sensitivity of cost to pertrubation from ground truth)
        % Hessian (eigenvalues and consistency of their ratios, eigenvectors)
        % Time to run findEdges
        % Time to run evaluateEdgeCost initially
        % Time to run evaluateEdgeCost repeated
        
      fprintf('\n\n*** End Measure Test ***');
    end
  end
  
end
