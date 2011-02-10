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
      
      %TODO: Figure out why FastPBM returns no edges to this function, use
      %another measure for now
      
      
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
          
          if numel(edgeList) ~= 0
            zeroPose = tom.Pose;
            zeroPose.p = [0; 0; 0];
            zeroPose.q = [1; 0; 0; 0];
            baseTrajectory.setPerturbation(zeroPose);          
            basePose = baseTrajectory.evaluate(0);
            display(basePose);         
            edgeCosts = 0:size(edgeList);
            
            %Compute cost at ground truth, save for bias and granularity
            %computations
            for k = 1:numel(edgeList)
              edgeCosts(k) = measure.computeEdgeCost(baseTrajectory, edgeList(k));
            end
            
            %Set Trajectory Perturbation to matlab machine eps
            epsPose = tom.Pose;
            epsPose.p = [eps('double'); eps('double'); eps('double')];
            eulerAng = [eps('double'), eps('double'), eps('double')];
            epsPose.q = Euler2Quat(eulerAng);
            baseTrajectory.setPerturbation(epsPose); 
            %double eps utill a different cost is returned
            while 1            
              for k = 1:numel(edgeList)
                tmp = measure.computeEdgeCost(baseTrajectory, edgeList(k));
                if tmp ~= edgeCosts(k)
                  break;
                end
              end
              epsPose.p = 2 * epsPose.p;
              eulerAng = 2 * eulerAng;
              epsPose.q = Euler2Quat(eulerAng);
              baseTrajectory.setPerturbation(zeroPose);      
            end
                       
            %This becomes the granularity
            Granularity = epsPose.p(1);
            Bias =  mean(edgeCosts);
            
            
            fprintf('Granularity: %f', Granularity);
            fprintf('Bias: %f', Bias);
            
            %Compute Monotonicity
            %construct sample space based off granularity
            MonotinicityAry = zeros(10, size(edgeList));
            for i = 1:10        
              for k = 1:numel(edgeList)
                tmp = measure.computeEdgeCost(baseTrajectory, edgeList(k));
                MonotinicityAry(i,k) = 2* (tmp - edgeCosts(k)) / epsPose.p(1);
                edgeCosts(k) = tmp;
              end
              epsPose.p = 2 * epsPose.p;
              eulerAng = 2 * eulerAng;
              epsPose.q = Euler2Quat(eulerAng);
              baseTrajectory.setPerturbation(zeroPose);      
            end
            
            Monotinicity = mean(mean(MonotinicityAry));
            fprintf('Monotinicity: %f', Monotinicity);
            
          else
            fprintf('\nwarning: Skipping measure characterization. Measure has no edges.');              
          end
          
          
        end
      end
      
      fprintf('\n\n*** End Measure Test ***');
    end
  end
  
end
