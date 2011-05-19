classdef MeasureTest < handle
  
  properties (Constant=true, GetAccess=private)
    numRefresh = 20;
  end
  
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
    function this = MeasureTest(name, initialTime, uri)
      fprintf('\n\n*** Begin Measure Test ***\n');
      
      fprintf('\nuri =');
      assert(isa(uri, 'char'));
      fprintf(' ''%s''', uri);
      
      fprintf('\ntom.Measure.description =');
      text = tom.Measure.description(name);
      assert(isa(text, 'char'));
      fprintf(' %s', text);
      
      container = antbed.DataContainer.create(uri(8:end), initialTime);
      if(container.hasReferenceTrajectory())
        trajectory = container.getReferenceTrajectory();
      else
        trajectory = tom.DynamicModel.create('tom', initialTime, '');
      end
      
      fprintf('\ntrajectory =');
      assert(isa(trajectory, 'tom.Trajectory'));
      fprintf(' ok');
      
      fprintf('\ninitialTime =');
      interval = trajectory.domain();
      initialTime = interval.first;
      assert(isa(initialTime, 'tom.WorldTime'));
      fprintf(' %f', double(initialTime));
      
      fprintf('\ntom.Measure.create =');
      measure = tom.Measure.create(name, initialTime, uri);
      assert(isa(measure, 'tom.Measure'));
      fprintf(' ok');
      
      for count = 1:this.numRefresh
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
            imshow(costImage/4.5);
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
        if(~container.hasReferenceTrajectory())
          fprintf('\nwarning: Skipping measure characterization. No reference trajectory is available.');
        else
          edgeList = measure.findEdges(measure.first(), measure.last(), measure.first(), measure.last());
          baseTrajectory = antbed.TrajectoryPerturbation(trajectory);
          
          if numel(edgeList) ~= 0
            Granularity = zeros(1,7);
            Bias = zeros(1,7);
            Monotinicity = zeros(1,7);
            % (1) preturb in all directions
            % (2) preturb in 1st translation dimension
            % (3) preturb in 2nd translation dimension
            % (4) preturb in 3rd translation dimension
            % (5) preturb in 1st rotation dimension
            % (6) preturb in 2nd rotation dimension
            % (7) preturb in 3rd rotation dimension
            
            % axis angle matrix
            axisAng = [eps('double'),0,0,0,eps('double'),0,0; eps('double'),0,0,0,0,eps('double'),0; eps('double'),0,0,0,0,0,eps('double')];
            
            epsPose = repmat(tom.Pose, [1,7]);
            
            epsPose(1).p = [eps('double'); eps('double'); eps('double')];
            epsPose(1).q = AxisAngle2Quat(axisAng(:, 1));
            epsPose(2).p = [eps('double'); 0; 0];
            epsPose(2).q = AxisAngle2Quat(axisAng(:, 2));
            epsPose(3).p = [0; eps('double'); 0];
            epsPose(3).q = AxisAngle2Quat(axisAng(:, 3));
            epsPose(4).p = [0; 0; eps('double')];
            epsPose(4).q = AxisAngle2Quat(axisAng(:, 4));
            epsPose(5).p = [0; 0; 0];
            epsPose(5).q = AxisAngle2Quat(axisAng(:, 5));
            epsPose(6).p = [0; 0; 0];
            epsPose(6).q = AxisAngle2Quat(axisAng(:, 6));
            epsPose(7).p = [0; 0; 0];
            epsPose(7).q = AxisAngle2Quat(axisAng(:, 7));
            
            %iterate over the 7 types of tested perturbation
            msg = {'All translation and rotation dimensions' ; ...
                   'Translation dimension 1' ; ...
                   'Translation dimension 2' ; ...
                   'Translation dimension 3' ; ...
                   'Rotation dimension 1' ; ...
                   'Rotation dimension 2' ; ...
                   'Rotation dimension 3'};
            for e = 1:7  
              fprintf('* Current Dim: %s *\n',msg{e});
              zeroPose = tom.Pose;
              zeroPose.p = [0; 0; 0];
              zeroPose.q = [1; 0; 0; 0];
              currEps = eps('double');
              baseTrajectory.setPerturbation(zeroPose);
              edgeCosts = 0:size(edgeList);

              %Compute cost at ground truth, save for bias and granularity
              %computations
              for k = 1:numel(edgeList)
                edgeCosts(k) = measure.computeEdgeCost(baseTrajectory, edgeList(k));
              end
              fprintf('Ground Truth cost: %f\n', edgeCosts(1));

              %Set Trajectory Perturbation to matlab machine eps
              baseTrajectory.setPerturbation(epsPose(e));

              %double eps utill a different cost is returned
              step = 0;
              %step through doubleing distance everytime
              for i = 1:64
                stop = 0;
                step = i;
                result = 1:k;
                %step through each edge
                for k = 1:numel(edgeList)
                  result(k) = measure.computeEdgeCost(baseTrajectory, edgeList(k));
                  if result(k) ~= edgeCosts(k)
                    stop = 1;
                    break;
                  end
                end
                currEps = 2 * currEps;
                epsPose(e).p = 2 .* epsPose(e).p;
                axisAng(:,e) = 2 .* axisAng(:,e);
                epsPose(e).q = AxisAngle2Quat(axisAng(:,e));
                baseTrajectory.setPerturbation(epsPose(e));
                fprintf('Testing with value %f, cost: %f\n', currEps, result(1));
                if(stop==1)
                  break;
                end
              end

              %This becomes the granularity
              Granularity(e) = currEps;
              if(step == 64)
                Granularity(e) = inf;
              end
              Bias(e) =  mean(edgeCosts);



              %Compute Monotonicity
              %construct sample space based off granularity
              MonotinicityAry = zeros(10, numel(edgeList));
              for i = 1:10
                for k = 1:numel(edgeList)
                  tmp = measure.computeEdgeCost(baseTrajectory, edgeList(k));
                  MonotinicityAry(i,k) = 2* (tmp - edgeCosts(k)) / currEps;
                  edgeCosts(k) = tmp;
                end
                currEps = 2 * currEps;
                epsPose(e).p = 2 * epsPose(e).p;
                axisAng(:,e) = 2 .* axisAng(:,e);
                epsPose(e).q = AxisAngle2Quat(axisAng);
                baseTrajectory.setPerturbation(epsPose(e));
              end

              Monotinicity(e) = mean(mean(MonotinicityAry));

            end
            for e = 1:7
              fprintf('%s',msg{e});
              fprintf('\nGranularity: %f\n', Granularity(e));
              fprintf('Bias: %f\n', Bias(e));
              fprintf('Monotinicity: %f\n\n', Monotinicity(e));
            end
          else
            fprintf('\nwarning: Skipping measure characterization. Measure has no edges.');
          end
          
        end
      end
      
      fprintf('\n\n*** End Measure Test ***');
    end
    
  end
  
end

function q = AxisAngle2Quat(v)
  v1 = v(1, :);
  v2 = v(2, :);
  v3 = v(3, :);
  n = sqrt(v1.*v1+v2.*v2+v3.*v3);
  good = n>eps;
  ngood = n(good);
  N = numel(n);
  a = zeros(1, N);
  b = zeros(1, N);
  c = zeros(1, N);
  th2 = zeros(1, N);
  a(good) = v1(good)./ngood;
  b(good) = v2(good)./ngood;
  c(good) = v3(good)./ngood;
  th2(good) = ngood/2;
  s = sin(th2);
  q1 = cos(th2);
  q2 = s.*a;
  q3 = s.*b;
  q4 = s.*c;
  q = [q1; q2; q3; q4];
end
