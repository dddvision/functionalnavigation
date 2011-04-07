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
  
  methods (Access = public)
    function this = FastPBM(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);     
      if(~strncmp(uri, 'antbed:', 7))
        error('URI scheme not recognized');
      end
      container = antbed.DataContainer.create(uri(8:end), initialTime);
      list = container.listSensors('antbed.Camera');
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
      
      if(this.calibrate)
        if(hasReferenceTrajectory(container))
          this.generateModel(getReferenceTrajectory(container));
        else
          error('must supply a reference trajectory to perform calibration');
        end
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
      data = edgeCache(nA, nB, this);
      cost = computeCost(poseA, poseB, data.rayA, data.rayB, this.angularDeviation, this.maxCost);     
    end
  end
    
  methods (Access = private)
    function data = processNode(this, n)
      % enumerate features at this node
      num = this.tracker.numFeatures(n);
      k = (uint32(1):num)-uint32(1);

      % get feature identifiers  
      id = this.tracker.getFeatureID(n, k);

      % get rays
      ray = this.tracker.getFeatureRay(n, k);

      % store results
      data = struct('id', id, 'ray', ray);
    end

    function data = processEdge(this, nA, nB)
      % process individual nodes to extract features
      dataA = nodeCache(nA, this);
      dataB = nodeCache(nB, this);

      % find features common to both images, inputs must be double, first output is not needed
      [idAB, indexA, indexB] = intersect(double(dataA.id), double(dataB.id));

      % select data common to both images
      rayA = dataA.ray(:, indexA);
      rayB = dataB.ray(:, indexB);

      % store results
      data = struct('rayA', rayA, 'rayB', rayB);
    end
    
    function generateModel(this, groundTraj)      
      for k = 1:100
        this.tracker.refresh(groundTraj);
      end

      nFirst = this.tracker.first();
      nLast = this.tracker.last();
      edgeList = this.findEdges(nFirst, nLast, nFirst, nLast);

      for i = 1:numel(edgeList)
        nA = edgeList(i).first;
        nB = edgeList(i).second;

        % return 0 if the specified edge is not found in the graph
        isAdjacent = (nA<nB) && ...
          this.tracker.hasData() && ...
          (nA>=this.tracker.first()) && ...
          (nB<=this.tracker.last());
        if(~isAdjacent)
          return;
        end

        % return NaN if the graph edge extends outside of the trajectory domain
        tA = this.tracker.getTime(nA);
        tB = this.tracker.getTime(nB);
        interval = groundTraj.domain();
        if(tA<interval.first)
          return;
        end

        poseA = groundTraj.evaluate(tA);
        poseB = groundTraj.evaluate(tB);

        numA = this.tracker.numFeatures(nA);
        numB = this.tracker.numFeatures(nB);
        kA = (uint32(1):numA)-uint32(1);
        kB = (uint32(1):numB)-uint32(1);
        idA = this.tracker.getFeatureID(nA, kA);
        idB = this.tracker.getFeatureID(nB, kB);

        % find features common to both images
        [idAB, indexA, indexB] = intersect(double(idA), double(idB)); % only supports double
        kA = kA(indexA);
        kB = kB(indexB);

        % get corresponding rays
        rayA = this.tracker.getFeatureRay(nA, kA);
        rayB = this.tracker.getFeatureRay(nB, kB);

        modelErrors(poseA, poseB, rayA, rayB);
      end
    end
  end
  
end

function modelErrors(poseA, poseB, rayA, rayB)
  residual = computeResidual(poseA, poseB, rayA, rayB);
  mu = mean(residual);
  sigma = sqrt(sum(residual.*residual)/numel(residual));
  fprintf('\n\n*** Computed Calibration Parameters ***\n');
  fprintf('\nmu = %f (radians)', mu);
  fprintf('\nsigma = %f (radians)', sigma);

  % Y = normpdf(range,M,S);
  % Y = Y./max(Y);
  % figure(1),clf;
  % plot(range,Y,'.');
  % hold on;
  % plot(range,Nn,'.','Color','r');
  % hold off;
  % legend('Gaussian','Data');
  % SSE1 = sum((Nn-Y).^2)./length(range);
  % title(sprintf('SSE = %.4d%',SSE1));

  % % KDE METHOD
  % f = ksdensity(Errors,range);
  % f = f./max(f);
  % figure(3),clf;
  % plot(range,f,'.');
  % hold on;
  % plot(range,Nn,'.','Color','r');
  % hold off;
  % legend('KDE','Data');
  % SSE2 = sum((Nn-f).^2)./length(range);
  % title(sprintf('SSE = %.4d%',SSE2));
end

% Compute the residual error for each pair of rays
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
    normals = cross(repmat(translation, 1, size(rayA, 2)), rayA);

    % normalize the normals
    nNormals = normals./repmat(sqrt(sum(normals.^2)), 3, 1);
    % TODO: set the residual to zero when the absolute value of the
    % denominator is less than eps

    % calculate the error
    residual = dot(nNormals, rayB);
    % TODO: Consider taking the acos of the dot product to get angular error in radians.
    %       This change is debatable because it affects the shape of the distribution.
    % NOTE: rayB is guaranteed to have unit magnitude
  end
end

% TODO: ensure that mu=0 unless there is a strong theoretical argument against it
% TODO: supply normpdf without depending on MATLAB toolboxes
function cost = computeCost(poseA, poseB, rayA, rayB, sigma, maxCost)
  residual = computeResidual(poseA, poseB, rayA, rayB);
  residualNorm = residual/sigma;
  y = sum(residualNorm.*residualNorm); % sum of normalized squared residuals
  Pux = chisqpdf(y, length(residual)); % P(u|x)
  infN = chisqpdf(length(residual)-2, length(residual)); % ||P(u|x)||_inf
  
  if(infN*exp(-maxCost)<Pux)
    cost = -log(Pux/infN);
  else
    cost = maxCost;
  end
end

function y = chisqpdf(x, nu)
  a = nu/2;
  b = 2^a;
  c = b*gamma(a);
  y = ((x.^(a-1))./exp(x/2))./c;
end

function prob = normProb(x, mu, sigma)
  prob = exp(-0.5 * ((x - mu)./sigma).^2) ./ (sqrt(2*pi) .* sigma);
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

% Caches data indexed by individual indices
function data = nodeCache(n, obj)
  persistent cache
  nKey = ['n', sprintf('%d', n)];
  if( isfield(cache, nKey) )
    data = cache.(nKey);
  else
    data = obj.processNode(n);
    cache.(nKey) = data;
  end
end

% Caches data indexed by pairs of indices
function data = edgeCache(nA, nB, obj)
  persistent cache
  nAKey = ['a', sprintf('%d', nA)];
  nBKey = ['b', sprintf('%d', nB)];
  if( isfield(cache, nAKey)&&isfield(cache.(nAKey), nBKey) )
    data = cache.(nAKey).(nBKey);
  else
    data = obj.processEdge(nA, nB);
    cache.(nAKey).(nBKey) = data;
  end
end
