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
          fprintf('\nrefresh');
          measure.refresh(trajectory);
        end
        
        antbed.SensorTest(measure);
        fprintf('\n');
        
        if(measure.hasData())
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
      
      [scheme,resource]=strtok(uri,':');
      resource=resource(2:end);
      dc = antbed.DataContainer.create(resource, initialTime);
      
      edgeList = findEdges(measure,measure.first(),measure.last(),measure.first(),measure.last());
      
      if hasReferenceTrajectory(dc)
          groundTraj = getReferenceTrajectory(dc);          
          interval = domain(groundTraj);
          baseTrajectory = antbed.TrajectoryPerturbation(evaluate(groundTraj,interval.first),interval);
          zeroPose = tom.Pose;
          zeroPose.p = [0;0;0];
          zeroPose.q = [1;0;0;0];
          setPerturbation(baseTrajectory,zeroPose);
          traj = evaluate(baseTrajectory,0);
          traj
      else
          error('Need to test with a measure that has a refrence trajectory');
      end
      
        
      fprintf('\n\n*** End Measure Test ***');
    end
  end
  
end
