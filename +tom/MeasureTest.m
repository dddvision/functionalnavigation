classdef MeasureTest < handle
% Copyright 2011 Scientific Systems Company Inc., New BSD License
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
    function this = MeasureTest(name, initialTime, uri, characterizeMeasures)
      fprintf('\n\n*** Begin Measure Test ***\n');
      
      fprintf('\nuri =');
      assert(isa(uri, 'char'));
      fprintf(' ''%s''', uri);
      
      fprintf('\ntom.Measure.description =');
      text = tom.Measure.description(name);
      assert(isa(text, 'char'));
      fprintf(' %s', text);
      
      container = hidi.DataContainer.create(uri(6:end), initialTime);
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
      assert(isa(initialTime, 'double'));
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
        
        hidi.SensorTest(measure);
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
        
      if(~characterizeMeasures)
        % do nothing
      elseif(~measure.hasData())
        fprintf('\nWarning: Skipping measure characterization. Measure has no data.');
      elseif(~strncmp(uri, 'hidi:', 5))
        fprintf('\nWarning: Skipping measure characterization. URI scheme not recognized.');
      elseif(~container.hasReferenceTrajectory())
        fprintf('\nWarning: Skipping measure characterization. No reference trajectory is available.');
      else
        edgeList = measure.findEdges(measure.first(), measure.last(), measure.first(), measure.last());
        numEdges = numel(edgeList);
        if(numEdges==0)
          fprintf('\nWarning: Skipping measure characterization. Measure has no edges.');
        else
          x = tom.MeasureTestPerturbation(trajectory);
          edge = edgeList(1);
          interval.first = measure.getTime(edge.first);
          interval.second = measure.getTime(edge.second);
          granularity = computeGranularity(interval, x, measure, edge);
          for k = 2:numEdges
            edge = edgeList(k);
            interval.first = measure.getTime(edge.first);
            interval.second = measure.getTime(edge.second);
            granularity = min(granularity, computeGranularity(interval, x, measure, edge));
          end
          fprintf('\ngranularity.p = [%g; %g; %g]', granularity(1), granularity(2), granularity(3));
          fprintf('\ngranularity.q = [%g; %g; %g]', granularity(4), granularity(5), granularity(6));
          fprintf('\ngranularity.r = [%g; %g; %g]', granularity(7), granularity(8), granularity(9));
          fprintf('\ngranularity.s = [%g; %g; %g]', granularity(10), granularity(11), granularity(12));
          
%             Bias = zeros(1,7);
%             Monotinicity = zeros(1,7);
%                  
%             for e = 1:7  
%               fprintf('* Current Dim: %s *\n',msg{e});
%               zeroPose = tom.Pose;
%               zeroPose.p = [0; 0; 0];
%               zeroPose.q = [1; 0; 0; 0];
%               x.setPerturbation(zeroPose);
%               edgeCosts = 0:size(edgeList);
% 
%               %Compute cost at ground truth, save for bias and granularity computations
%               for k = 1:numel(edgeList)
%                 edgeCosts(k) = measure.computeEdgeCost(x, edgeList(k));
%               end
%               fprintf('Ground Truth cost: %f\n', edgeCosts(1));
% 
%               %Set Trajectory Perturbation to matlab machine eps
%               x.setPerturbation(epsPose(e));
% 
%               %double eps utill a different cost is returned
%               currEps = eps('double');
%               %step through doubleing distance everytime
%               step = 0;
%               for i = 1:64
%                 stop = 0;
%                 step = i;
%                 result = 1:k;
%                 %step through each edge
%                 for k = 1:numel(edgeList)
%                   result(k) = measure.computeEdgeCost(x, edgeList(k));
%                   if result(k) ~= edgeCosts(k)
%                     stop = 1;
%                     break;
%                   end
%                 end
%                 currEps = 2 * currEps;
%                 epsPose(e).p = 2*epsPose(e).p;
%                 axisAng(:,e) = 2*axisAng(:,e);
%                 epsPose(e).q = tom.Rotation.axisToQuat(axisAng(:,e));
%                 x.setPerturbation(epsPose(e));
%                 fprintf('Testing with value %f, cost: %f\n', currEps, result(1));
%                 if(stop==1)
%                   break;
%                 end
%               end
% 
%               %This becomes the granularity
%               Granularity(e) = currEps;
%               if(step == 64)
%                 Granularity(e) = inf;
%               end
%               Bias(e) =  mean(edgeCosts);
% 
%               %Compute Monotonicity
%               %construct sample space based off granularity
%               MonotinicityAry = zeros(10, numel(edgeList));
%               for i = 1:10
%                 for k = 1:numel(edgeList)
%                   tmp = measure.computeEdgeCost(x, edgeList(k));
%                   MonotinicityAry(i,k) = 2*(tmp-edgeCosts(k))/currEps;
%                   edgeCosts(k) = tmp;
%                 end
%                 currEps = 2 * currEps;
%                 epsPose(e).p = 2*epsPose(e).p;
%                 axisAng(:,e) = 2*axisAng(:,e);
%                 epsPose(e).q = tom.Rotation.axisToQuat(axisAng);
%                 x.setPerturbation(epsPose(e));
%               end
% 
%               Monotinicity(e) = mean(mean(MonotinicityAry));
%             end
%             
%             for e = 1:7
%               fprintf('%s',msg{e});
%               fprintf('\nGranularity: %f\n', Granularity(e));
%               fprintf('Bias: %f\n', Bias(e));
%               fprintf('Monotinicity: %f\n\n', Monotinicity(e));
%             end
        end
      end
      fprintf('\n\n*** End Measure Test ***');
    end
  end
end

function cost = MTEval(interval, x, measure, edge, delta)
  perturb = tom.TangentPose;
  perturb.p = delta(1:3);
  perturb.q = tom.Rotation.axisToQuat(delta(4:6));
  perturb.r = delta(7:9);
  perturb.s = delta(10:12);
  x.setPerturbation(interval, perturb);
  cost = measure.computeEdgeCost(x, edge);
end

% Searches for the location of the smallest deviation from costCenter
function granularity = computeGranularity(interval, x, measure, edge)
  DIM = 12;
  costCenter = MTEval(interval, x, measure, edge, zeros(12, 1));
  granularity = zeros(DIM, 1);
  for dim = 1:DIM
    infinite = true;
    delta = zeros(DIM, 1);
    for positiveScale = (10.^(-16:16))
      delta(dim) = positiveScale;
      cost = MTEval(interval, x, measure, edge, delta);
      if(unequal(cost, costCenter))
        for upperBound = (positiveScale*(0.2:0.1:1))
          delta(dim) = upperBound;
          cost = MTEval(interval, x, measure, edge, delta);
          if(unequal(cost, costCenter))
            break;
          end
        end
        infinite = false;
        break;
      end
    end
    for negativeScale = -(10.^(-16:16))
      delta(dim) = negativeScale;
      cost = MTEval(interval, x, measure, edge, delta);
      if(unequal(cost, costCenter))
        for lowerBound = (negativeScale*(0.2:0.1:1))
          delta(dim) = lowerBound;
          cost = MTEval(interval, x, measure, edge, delta);
          if(unequal(cost, costCenter))
            break;
          end
        end
        infinite = false;
        break;
      end
    end
    if(infinite)
      granularity(dim) = Inf;
    else
      granularity(dim) = upperBound-lowerBound;
    end
  end
end

function flag = unequal(a, b)
  flag = typecast(a, 'uint64')~=typecast(b, 'uint64');
end
