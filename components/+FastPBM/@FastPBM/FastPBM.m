classdef FastPBM < FastPBM.FastPBMConfig & tom.Measure
  
  properties (SetAccess = private, GetAccess = private)
    sensor
    tracker
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'Implements a fast visual feature tracker and associated trajectory measure.';
      end
      tom.Measure.connect(name, @componentDescription, @FastPBM.FastPBM);
    end
  end
  
  methods (Static = true, Access = public)
    % Perform calibration using MiddleburyData
    function calibrate(initialTime, uri)
      fprintf('\n\n*** Computing Calibration Parameters (radians) ***\n');
      breakpoints = dbstatus('-completenames');
      save('temp.mat', 'breakpoints', 'initialTime', 'uri');
      close('all');
      clear('classes');
      load('temp.mat');
      dbstop(breakpoints);
      
      % initialize the default pseudorandom number generator
      RandStream.getDefaultStream.reset();
      
      this = tom.Measure.create('FastPBM', initialTime, uri);
      container = antbed.DataContainer.create(uri(8:end), initialTime);
      groundTraj = container.getReferenceTrajectory();
        
      for k = 1:100
        this.tracker.refresh(groundTraj);
      end

      nFirst = this.tracker.first();
      nLast = this.tracker.last();
      edgeList = this.findEdges(nFirst, nLast, nFirst, nLast);
      numEdges = numel(edgeList);

      partialResidual = cell(0, numEdges);
      residual = [];
      for i = 1:numEdges
        nA = edgeList(i).first;
        nB = edgeList(i).second;

        tA = this.tracker.getTime(nA);
        tB = this.tracker.getTime(nB);

        poseA = groundTraj.evaluate(tA);
        poseB = groundTraj.evaluate(tB);

        [indexA, indexB] = this.tracker.findMatches(nA, nB);
        rayA = this.tracker.getFeatureRay(nA, indexA);
        rayB = this.tracker.getFeatureRay(nB, indexB);
        
        partialResidual{i} = computeResidual(poseA, poseB, rayA, rayB);

        residual = [residual, partialResidual{i}];
      end
      
      Ppos = zeros(1, numEdges);
      Pneg = zeros(1, numEdges);
      for i = 1:numEdges
        N = numel(partialResidual{i});
        Nz = sum(partialResidual{i}==0);
        Ppos(i) = sum(partialResidual{i}>0)/(N-Nz);
        Pneg(i) = sum(partialResidual{i}<0)/(N-Nz);
      end
      deviation = sqrt(sum(([Ppos, Pneg]-0.5).^2)/(numEdges-1))
    end
  end
  
  methods (Access = public)
    function this = FastPBM(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);
      
      if(~strncmp(uri, 'antbed:', 7))
        error('URI scheme not recognized');
      end
      container = antbed.DataContainer.create(uri(8:end), initialTime);
      list = container.listSensors('antbed.Camera');
      if(isempty(list))
        error('At least one camera must be present in the data container');
      end
      
      % get the first camera
      this.sensor = container.getSensor(list(1));

      % instantiate the tracker by name
      switch(this.trackerName)
      case 'SparseTrackerKLT'
        this.tracker = FastPBM.SparseTrackerKLT(initialTime, this.sensor);
      case 'SparseTrackerSURF'
        this.tracker = FastPBM.SparseTrackerSURF(initialTime, this.sensor);
      otherwise
        error('unrecognized tracker');
      end
    end
    
    function refresh(this, x)
      this.tracker.refresh(x);
    end
    
    function flag = hasData(this)
      flag = this.tracker.hasData();
    end
    
    function n = first(this)
      n = this.tracker.first();
    end
    
    function n = last(this)
      n = this.tracker.last();
    end
    
    function time = getTime(this, n)
      time = this.tracker.getTime(n);
    end
    
    function edgeList = findEdges(this, naMin, naMax, nbMin, nbMax)
      edgeList = repmat(tom.GraphEdge, [0, 1]);
      if(this.tracker.hasData())
        nMin = max([naMin, this.tracker.first(), nbMin-uint32(1)]);
        nMax = min([naMax+uint32(1), this.tracker.last(), nbMax]);
        nList = nMin:nMax;
        [nb, na] = ndgrid(nList, nList);
        keep = nb(:)>na(:);
        na = na(keep);
        nb = nb(keep);
        if(~isempty(na))
          edgeList = tom.GraphEdge(na, nb);
        end
      end
    end
    
    function cost = computeEdgeCost(this, x, graphEdge)     
      nA = graphEdge.first;
      nB = graphEdge.second;
      
      % return 0 if the specified edge is not found in the graph
      isAdjacent = (nA<nB) && ...
        this.tracker.hasData() && ...
        (nA>=this.tracker.first()) && ...
        (nB<=this.tracker.last());
      if(~isAdjacent)
        cost = 0;
        return;
      end
      
      % return NaN if the graph edge extends outside of the trajectory domain
      tA = this.tracker.getTime(nA);
      tB = this.tracker.getTime(nB);
      interval = x.domain();
      if(tA<interval.first)
        cost = NaN;
        return;
      end
      
      poseA = x.evaluate(tA);
      poseB = x.evaluate(tB);
      
      [indexA, indexB] = this.tracker.findMatches(nA, nB);
      rayA = this.tracker.getFeatureRay(nA, indexA);
      rayB = this.tracker.getFeatureRay(nB, indexB);
      
      cost = computeCost(poseA, poseB, rayA, rayB, this.deviation);     
    end
  end

end

% Compute the residual error for each pair of rays
%
% NOTES
% The input rays are assumed to have a unit magnitude
function residual = computeResidual(poseA, poseB, rayA, rayB)
  % adjust for rotation
  RA = Quat2Matrix(poseA.q);
  RB = Quat2Matrix(poseB.q);
  rayA = RA*rayA;
  rayB = RB*rayB;

  % evaluate translation component
  translation = poseB.p-poseA.p;
  if( norm(translation)<eps )
    residual = acos(dot(rayA, rayB));
  else
    % calculate the normal to the epipolar plane
    normals = bsxfun(@cross, translation, rayA);
    magnitude = sqrt(sum(normals.*normals));
    magnitude(magnitude<eps) = eps;
    normals = bsxfun(@rdivide, normals, magnitude);
    
    % calculate the error in radians
    residual = asin(dot(normals, rayB));
  end
end

function cost = computeCost(poseA, poseB, rayA, rayB, deviation)
  residual = computeResidual(poseA, poseB, rayA, rayB);
  N = numel(residual);
  Nz = sum(residual==0);
  Ppos = sum(residual>0)/(N-Nz);
  z = (Ppos-0.5)/deviation;
  cost = 0.5*z*z;
end

% Converts a quaternion to a rotation matrix
%
% Q = body orientation in quaternion <scalar, vector> form,  double 4-by-1
% R = matrix that represents the body frame in the world frame,  double 3-by-3
function R = Quat2Matrix(Q)
  q1 = Q(1);
  q2 = Q(2);
  q3 = Q(3);
  q4 = Q(4);

  q11 = q1*q1;
  q22 = q2*q2;
  q33 = q3*q3;
  q44 = q4*q4;

  q12 = q1*q2;
  q23 = q2*q3;
  q34 = q3*q4;
  q14 = q1*q4;
  q13 = q1*q3;
  q24 = q2*q4;

  R = zeros(3, 3);

  R(1, 1) = q11+q22-q33-q44;
  R(2, 1) = 2*(q23+q14);
  R(3, 1) = 2*(q24-q13);

  R(1, 2) = 2*(q23-q14);
  R(2, 2) = q11-q22+q33-q44;
  R(3, 2) = 2*(q34+q12);

  R(1, 3) = 2*(q24+q13);
  R(2, 3) = 2*(q34-q12);
  R(3, 3) = q11-q22-q33+q44;
end
