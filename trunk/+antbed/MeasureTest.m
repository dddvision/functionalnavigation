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
            imshow(costImage/9);
            title('Cost');
          end
        end
      end
        
%       if(~measure.hasData())
%         fprintf('\nwarning: Skipping measure characterization. Measure has no data.');
%       elseif(~strncmp(uri, 'antbed:', 7))
%         fprintf('\nwarning: Skipping measure characterization. URI scheme not recognized');
%       else
%         resource = uri(8:end);
%         container = antbed.DataContainer.create(resource, initialTime);
%         if(~hasReferenceTrajectory(container))
%           fprintf('\nwarning: Skipping measure characterization. No reference trajectory is available.');
%         else
%           edgeList = measure.findEdges(measure.first(), measure.last(), measure.first(), measure.last());
%           groundTraj = container.getReferenceTrajectory();
%           interval = groundTraj.domain();
%           baseTrajectory = antbed.TrajectoryPerturbation(groundTraj.evaluate(interval.first), interval);
%           
%           edgeList
%           
%           if numel(edgeList) ~= 0
%             zeroPose = tom.Pose;
%             zeroPose.p = [0; 0; 0];
%             zeroPose.q = [1; 0; 0; 0];
%             baseTrajectory.setPerturbation(zeroPose);
%             basePose = baseTrajectory.evaluate(0);
%             display(basePose);
%             edgeCosts = 0:size(edgeList);
%             
%             %Compute cost at ground truth, save for bias and granularity
%             %computations
%             for k = 1:numel(edgeList)
%               edgeCosts(k) = measure.computeEdgeCost(baseTrajectory, edgeList(k));
%             end
%             
%             %Set Trajectory Perturbation to matlab machine eps
%             epsPose = tom.Pose;
%             epsPose.p = [eps('double'); eps('double'); eps('double')];
%             axisAng = [eps('double'); eps('double'); eps('double')];
%             epsPose.q = AxisAngle2Quat(axisAng);
%             baseTrajectory.setPerturbation(epsPose);
%             %double eps utill a different cost is returned
%             while 1
%               for k = 1:numel(edgeList)
%                 tmp = measure.computeEdgeCost(baseTrajectory, edgeList(k));
%                 if tmp ~= edgeCosts(k)
%                   break;
%                 end
%               end
%               epsPose.p = 2 * epsPose.p;
%               axisAng = 2 * axisAng;
%               epsPose.q = AxisAngle2Quat(axisAng);
%               baseTrajectory.setPerturbation(zeroPose);
%               fprintf('Testing with value %f, cost: %f\n', epsPose.p(1), edgeCosts(1));
%             end
%             
%             %This becomes the granularity
%             Granularity = epsPose.p(1);
%             Bias =  mean(edgeCosts);
%             
%             
%             fprintf('Granularity: %f', Granularity);
%             fprintf('Bias: %f', Bias);
%             
%             %Compute Monotonicity
%             %construct sample space based off granularity
%             MonotinicityAry = zeros(10, size(edgeList));
%             for i = 1:10
%               for k = 1:numel(edgeList)
%                 tmp = measure.computeEdgeCost(baseTrajectory, edgeList(k));
%                 MonotinicityAry(i,k) = 2* (tmp - edgeCosts(k)) / epsPose.p(1);
%                 edgeCosts(k) = tmp;
%               end
%               epsPose.p = 2 * epsPose.p;
%               axisAng = 2 * axisAng;
%               epsPose.q = AxisAngle2Quat(axisAng);
%               baseTrajectory.setPerturbation(zeroPose);
%             end
%             
%             Monotinicity = mean(mean(MonotinicityAry));
%             fprintf('Monotinicity: %f', Monotinicity);
%             
%           else
%             fprintf('\nwarning: Skipping measure characterization. Measure has no edges.');
%           end
%           
%         end
%       end
      
      fprintf('\n\n*** End Measure Test ***');
    end
    
  end
  
end

% function q = AxisAngle2Quat(v)
%   v1 = v(1, :);
%   v2 = v(2, :);
%   v3 = v(3, :);
%   n = sqrt(v1.*v1+v2.*v2+v3.*v3);
%   good = n>eps;
%   ngood = n(good);
%   N = numel(n);
%   a = zeros(1, N);
%   b = zeros(1, N);
%   c = zeros(1, N);
%   th2 = zeros(1, N);
%   a(good) = v1(good)./ngood;
%   b(good) = v2(good)./ngood;
%   c(good) = v3(good)./ngood;
%   th2(good) = ngood/2;
%   s = sin(th2);
%   q1 = cos(th2);
%   q2 = s.*a;
%   q3 = s.*b;
%   q4 = s.*c;
%   q = [q1; q2; q3; q4];
% end
