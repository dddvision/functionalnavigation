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
      
      if(~measure.hasData())
        fprintf('\nwarning: Skipping measure characterization. Measure has no data.');
      elseif(~strncmp(uri, 'antbed:', 7))
        fprintf('\nwarning: Skipping measure characterization. URI scheme not recognized');
      else
        resource = uri(8:end);
        container = antbed.DataContainer.create(resource, initialTime);
        if(~hasReferenceTrajectory(container))
          fprintf('\nwarning: Skipping measure characterization. No reference trajectory is available.');
        else
          edgeList = measure.findEdges(measure.first(), measure.last(), measure.first(), measure.last());
          groundTraj = container.getReferenceTrajectory();
          interval = groundTraj.domain();
          baseTrajectory = antbed.TrajectoryPerturbation(groundTraj.evaluate(interval.first), interval);
          zeroPose = tom.Pose;
          zeroPose.p = [0; 0; 0];
          zeroPose.q = [1; 0; 0; 0];
          baseTrajectory.setPerturbation(zeroPose);
          basePose = baseTrajectory.evaluate(0);
          display(basePose);
        end
      end
      
      fprintf('\n\n*** End Measure Test ***');
    end
  end
  
end
