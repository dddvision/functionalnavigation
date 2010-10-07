classdef MeasureTest < handle
  
  methods (Access = private, Static = true)
    function handle = figureHandle
      persistent h
      if(isempty(h))
        h = figure;
        set(h, 'Name', 'Cost graph');
      end
      handle = h;
    end        
  end
  
  methods (Access = public, Static = true)
    function this = MeasureTest(name, trajectory, uri)
      fprintf('\n\n*** Begin Measure Test ***\n');
      
      fprintf('\ntrajectory =');
      assert(isa(trajectory, 'tom.Trajectory'));
      fprintf(' ok');
      
      fprintf('\ninitialTime =');
      interval = trajectory.domain();
      initialTime = interval.first;
      assert(isa(initialTime, 'tom.WorldTime'));
      fprintf(' %f', double(initialTime));
      
      fprintf('\nuri =');
      assert(isa(uri, 'char'));
      fprintf(' ''%s''', uri);
      
      fprintf('\ntom.Measure.description =');
      text = tom.Measure.description(name);
      assert(isa(text, 'char'));
      fprintf(' %s', text);
      
      fprintf('\ntom.Measure.create =');
      measure = tom.Measure.create(name, initialTime, uri);
      assert(isa(measure, 'tom.Measure'));
      fprintf(' ok');
      
      for count = 1:4
        if(count>1)
%           fprintf('\n\npause');
%           pause(1);

          fprintf('\nrefresh');
          measure.refresh(trajectory);
        end
        
        testbed.SensorTest(measure);

        if(measure.hasData())
          fprintf('\n\nfindEdges =');
          first = measure.first();
          last = measure.last();
          edges = measure.findEdges(first, last, first, last);
          display(edges);
        
          numEdges = numel(edges);
          if(numEdges>0)
            nA = zeros(numel(edges),1);
            nB = zeros(numel(edges),1);
            for k = 1:numEdges
              nA(k) = edges(k).first;
              nB(k) = edges(k).second;
            end
            nMin = min(nA);
            nMax = max(nB);
            span = nMax-nMin+uint32(1);
            
            adjacencyImage = false(span,span);
            costImage = zeros(span,span);
            for k = 1:numEdges
              adjacencyImage(nA(k)-nMin+1,nB(k)-nMin+1) = true;
              costImage(nA(k)-nMin+1,nB(k)-nMin+1) = measure.computeEdgeCost(trajectory, edges(k));
            end
            
            figure(this.figureHandle);
            subplot(1, 2, 1);
            cla;
            imshow(adjacencyImage);
            title('Adjacency');
            subplot(1, 2, 2);
            cla;
            imshow(costImage/9);
            title('Cost');
          end
        end
      end
      
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
