classdef FastPBM < FastPBM.FastPBMConfig & tom.Measure
  
  properties (SetAccess = private, GetAccess = private)
    sensor
    tracker
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = ['Implements multiple visual feature trackers and trajectory measures. ', ...
          'Tracker choices include SURF, OpenCV KLT 2.0.0, and a faster version of KLT that is less accurate. ', ...
          'This measure depends on at least one hidi Camera object.'];
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
      RandStream.getDefaultStream.reset(); %#ok until deprecated by MATLAB
      
      this = tom.Measure.create('FastPBM', initialTime, uri);
      container = hidi.DataContainer.create(uri(6:end), initialTime);
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
        nodeA = edgeList(i).first;
        nodeB = edgeList(i).second;

        [rayA, rayB] = this.tracker.findMatches(nodeA, nodeB);
        
        partialResidual{i} = this.computeResidual(groundTraj, nodeA, nodeB, rayA, rayB);

        residual = cat(2, residual, partialResidual{i});
      end
      
      theta = this.getNyquist();
      
      P = zeros(1, numEdges);
      for i = 1:numEdges
        P(i) = halfSpaceTest(partialResidual{i}, theta);
      end
      display(P);
      deviation = sqrt(sum((P-0.5).^2)/(numEdges-1));
      display(deviation);
    end
  end
  
  methods (Access = public)
    function this = FastPBM(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);
      if(this.verbose)
        fprintf('\nInitializing %s\n', class(this));
      end
      
      % get the first camera from the data container
      if(~strncmp(uri, 'hidi:', 5))
        error('URI scheme not recognized');
      end
      container = hidi.DataContainer.create(uri(6:end), initialTime);
      list = container.listSensors('hidi.Camera');
      if(isempty(list))
        error('At least one camera must be present in the data container');
      end
      this.sensor = container.getSensor(list(1));

      % instantiate the tracker by name
      switch(this.trackerName)
      case 'KLT'
        this.tracker = FastPBM.KLT(initialTime, this.sensor);
      case 'KLTOpenCV'
        this.tracker = FastPBM.KLTOpenCV(initialTime, this.sensor);
      case 'SURF'
        this.tracker = FastPBM.SURF(initialTime, this.sensor);
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
        naMin = max([naMin, this.tracker.first(), nbMin-uint32(1)]);
        naMax = min([naMax, this.tracker.last()-uint32(1), nbMax-uint32(1)]);
        a = naMin:naMax;
        if(naMax>=naMin)
          edgeList = tom.GraphEdge(a, a+uint32(1));
        end
      end
    end
    
    function cost = computeEdgeCost(this, x, graphEdge)     
      nodeA = graphEdge.first;
      nodeB = graphEdge.second;
      
      % return 0 if the specified edge is not found in the graph
      isAdjacent = ((nodeA+uint32(1))==nodeB) && ...
        this.tracker.hasData() && ...
        (nodeA>=this.tracker.first()) && ...
        (nodeB<=this.tracker.last());
      if(~isAdjacent)
        cost = 0;
        return;
      end
      
      [rayA, rayB] = this.tracker.findMatches(nodeA, nodeB);
      
      residual = this.computeResidual(x, nodeA, nodeB, rayA, rayB);
      
      pHalfSpace = halfSpaceTest(residual, this.getNyquist());
      z = (pHalfSpace-0.5)/this.deviation;
      cost = 0.5*z*z;
    end
    
    function theta = getNyquist(this)
      steps = double(this.sensor.numSteps());
      strides = double(this.sensor.numStrides());
      center = round([strides/2; steps/2]);
      pix = [center+[1; 1], center-[1; 1]];
      ray = this.sensor.inverseProjection(pix);
      theta = acos(ray(:, 1)'*ray(:, 2));
    end
    
    % Compute the residual error for each pair of rays
    %
    % NOTES
    % The input rays are assumed to have a unit magnitude
    function residual = computeResidual(this, x, nodeA, nodeB, rayA, rayB)
      % return NaN if the graph edge extends outside of the trajectory domain
      tA = this.tracker.getTime(nodeA);
      tB = this.tracker.getTime(nodeB);
      interval = x.domain();
      if(tA<interval.first)
        residual = NaN;
        return;
      end
      
      % get poses
      poseA = x.evaluate(tA);
      poseB = x.evaluate(tB);
      
      % adjust for rotation
      RA = tom.Rotation.quatToMatrix(poseA.q);
      RB = tom.Rotation.quatToMatrix(poseB.q);
      rayRA = RA*rayA;
      rayRB = RB*rayB;

      % evaluate translation component
      dx = poseB.p-poseA.p;
      if( norm(dx)<eps )
        residual = acos(dot(rayRA, rayRB));
      else
        % calculate the normal to the epipolar plane
        normals = crossMatrix(dx)*rayRA;
        magnitude = sqrt(sum(normals.*normals));
        magnitude(magnitude<eps) = eps;
        normals = bsxfun(@rdivide, normals, magnitude);

        % calculate the error in radians
        residual = asin(dot(normals, rayRB));
      end
      
      % optionally display results
      if(this.displayResults)
        this.putResults(nodeA, nodeB, rayA, rayB);
      end
    end
    
    function putResults(this, nodeA, nodeB, rayA, rayB)
      persistent figureHandle
      if(isempty(figureHandle))
        figureHandle = figure;
      else
        figure(figureHandle);
      end
      cla;
      imageA = this.sensor.getImageUInt8(nodeA, uint32(0), uint8(0)); % process red only for speed
      imageB = this.sensor.getImageUInt8(nodeB, uint32(0), uint8(0)); % process red only for speed
      imshow(cat(3, zeros(size(imageA)), 0.5+(imageA-imageB)/2, 0.5+(imageB-imageA)));
      axis('image');
      hold('on');
      pixA = this.sensor.projection(rayA);
      pixB = this.sensor.projection(rayB);
      line([pixA(1, :); pixB(1, :)]+1, [pixA(2, :); pixB(2, :)]+1, 'Color', 'r');
      drawnow;
    end
  end

end

% Smooth positivity test function with domain [-Inf, Inf] and range [0, 1]
function p = halfSpaceTest(r, nyquist)
  N = numel(r);
  if(N>0)
    p = sum((1+erf(r/nyquist)))/(2*N); % faster than atan
  else
    p = 0.5;
  end
end

function y = crossMatrix(x)
  y = [0, -x(3), x(2); x(3), 0, -x(1); -x(2), x(1), 0];
end

function cost = computeCost2(poseA, poseB, rayA, rayB, deviation)
  data = edgeCache(nodeA, nodeB, this);
  u = transpose(data.pixB(:, 1)-data.pixA(:, 1));
  v = transpose(data.pixB(:, 2)-data.pixA(:, 2));
  Ea = tom.Rotation.quatToEuler(poseA.q);
  Eb = tom.Rotation.quatToEuler(poseB.q);
  translation = [poseB.p(1)-poseA.p(1);
    poseB.p(2)-poseA.p(2);
    poseB.p(3)-poseA.p(3)];
  rotation = [Eb(1)-Ea(1);
    Eb(2)-Ea(2);
    Eb(3)-Ea(3)];
  [uvr, uvt] = generateFlowSparse(this, translation, rotation, transpose(data.pixA));
 
  % Seperate flow components
  Vxr=uvr(1,:);
  Vyr=uvr(2,:);
  Vxt=uvt(1,:);
  Vyt=uvt(2,:);

  % Remove rotation effect
  Vx_OFT=(Vx_OF-Vxr);
  Vy_OFT=(Vy_OF-Vyr);
  
  % Drop magnitude of translation
  mag=sqrt(Vxt.*Vxt+Vyt.*Vyt);
  mag(mag(:)<eps)=1; 
  Vxt=Vxt./mag;
  Vyt=Vyt./mag;
  
  % Drop magnitude of translation
  mag=sqrt(Vx_OFT.*Vx_OFT+Vy_OFT.*Vy_OFT);
  mag(mag(:)<eps)=1; 
  Vx_OFTD=Vx_OFT./mag;
  Vy_OFTD=Vy_OFT./mag;
  
  % remove NaNs
  Vx_OFTD(isnan(Vx_OFTD))=0;
  Vy_OFTD(isnan(Vy_OFTD))=0;
  
  % Euclidean distance
  ErrorX=(Vx_OFTD-Vxt);
  ErrorY=(Vy_OFTD-Vyt);
  ErrorMag=sqrt(ErrorX.*ErrorX+ErrorY.*ErrorY);
  upperBound=2*numel(Vx_OF);

% % Absolute angular distance
%   ErrorMag=abs(acos(Vx_OFTD.*Vxt+Vy_OFTD.*Vyt));
%   upperBound=pi*numel(Vx_OF);
  
  cost=sum(ErrorMag(:))*(this.maxCost/upperBound);
end

% Generate instantaneous optical flow field based on camera projection
%
% INPUT
% deltap = change in position, double 1-by-3
% deltaEuler = change in Euler angles, double 1-by-3
% pix = points in pixel coordinates, double 2-by-P
% nA = data node at which to compute the image projection, uint32 scalar
%
% OUTPUT
% uvr = flow in pixel coordinates due to rotation, double 2-by-P
% uvt = flow in pixel coordinates due to translation, double 2-by-P
%
% NOTES
% For pixel coordinate interpretation, see hidi.Camera.projection()
% Algorithm is based on:
%   http://code.google.com/p/functionalnavigation/wiki/MotionInducedOpticalFlow
function [uvr, uvt] = generateFlowSparse(this, deltap, deltaEuler, pix)
  % Put the pixel coordinates through the inverse camera projection to get ray vectors
  c = this.sensor.inverseProjection(pix);

  % Compute the rotation matrix R that represents the camera frame at time tb
  % relative to the camera frame at time ta.
  s1 = sin(deltaEuler(1));
  c1 = cos(deltaEuler(1));
  s2 = sin(deltaEuler(2));
  c2 = cos(deltaEuler(2));
  s3 = sin(deltaEuler(3));
  c3 = cos(deltaEuler(3));
  R = [c3*c2, c3*s2*s1-s3*c1, s3*s1+c3*s2*c1; s3*c2, c3*c1+s3*s2*s1, s3*s2*c1-c3*s1; -s2, c2*s1, c2*c1];

  % Rotate the ray vectors by pre-multiplying by the transpose of the rotation matrix
  c_new = transpose(R)*c; 

  % Put the new rays through the forward camera projection to get new pixel coordinates
  pix_new = this.sensor.projection(c_new);

  % The rotational flow field is the pixel coordinate difference
  uvr = pix_new-pix;
  
  % Convert NaN to zero
  uvr(isnan(uvr(:))) = 0;

  % Normalize the translation vector to a length that is very small relative to a unit magnitude
  T_mag = sqrt(dot(deltap, deltap));
  if(T_mag<eps)
    T_norm = zeros(3, 1);
  else
    T_norm = (1E-6)*deltap/T_mag;
  end

  % Translate the camera rays by the negative of the camera translation
  c_new = c-repmat(T_norm, [1, size(c, 2)]);

  % Put the new rays through the forward camera projection to get new pixel coordinates
  pix_new = this.sensor.projection(c_new);

  % The translational flow field is the pixel coordinate difference
  uvt = pix_new-pix;
  
  % Convert NaN to zero
  uvt(isnan(uvt(:))) = 0;
end
