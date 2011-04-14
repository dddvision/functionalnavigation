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
          'This measure depends on at least one antbed.Camera object.'];
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
        nodeA = edgeList(i).first;
        nodeB = edgeList(i).second;

        tA = this.tracker.getTime(nodeA);
        tB = this.tracker.getTime(nodeB);

        poseA = groundTraj.evaluate(tA);
        poseB = groundTraj.evaluate(tB);

        [rayA, rayB] = this.tracker.findMatches(nodeA, nodeB);
        
        partialResidual{i} = computeResidual(poseA, poseB, rayA, rayB);

        residual = cat(2, residual, partialResidual{i});
        fprintf('\nresidual = ');
        fprintf('%e', residual);
      end
      
      Ppos = zeros(1, numEdges);
      Pneg = zeros(1, numEdges);
      for i = 1:numEdges
        N = numel(partialResidual{i});
        Nz = sum(partialResidual{i}==0);
        Ppos(i) = sum(partialResidual{i}>0)/(N-Nz);
        Pneg(i) = sum(partialResidual{i}<0)/(N-Nz);
      end
      deviation = sqrt(sum(([Ppos, Pneg]-0.5).^2)/(numEdges-1));
      fprintf('\ndeviation = %e', deviation);
    end
  end
  
  methods (Access = public)
    function this = FastPBM(initialTime, uri)
      this = this@tom.Measure(initialTime, uri);
      if(this.verbose)
        fprintf('\nInitializing %s\n', class(this));
      end
      
      % get the first camera from the data container
      if(~strncmp(uri, 'antbed:', 7))
        error('URI scheme not recognized');
      end
      container = antbed.DataContainer.create(uri(8:end), initialTime);
      list = container.listSensors('antbed.Camera');
      if(isempty(list))
        error('At least one camera must be present in the data container');
      end
      this.sensor = container.getSensor(list(1));

      % instantiate the tracker by name
      switch(this.trackerName)
      case 'SparseTrackerKLT'
        this.tracker = FastPBM.SparseTrackerKLT(initialTime, this.sensor);
      case 'SparseTrackerKLTOpenCV'
        this.tracker = FastPBM.SparseTrackerKLTOpenCV(initialTime, this.sensor);
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
%       edgeList = repmat(tom.GraphEdge, [0, 1]);
%       if(this.tracker.hasData())
%         naMin = max([naMin, this.tracker.first(), nbMin-uint32(1)]);
%         naMax = min([naMax, this.tracker.last()-uint32(1), nbMax-uint32(1)]);
%         a = naMin:naMax;
%         if(naMax>=naMin)
%           edgeList = tom.GraphEdge(a, a+uint32(1));
%         end
%       end
      edgeList = repmat(tom.GraphEdge, [0, 1]);
      if(this.tracker.hasData())
        nMin = max([naMin, this.tracker.first(), nbMin-uint32(1)]);
        nMax = min([naMax+uint32(1), this.tracker.last(), nbMax]);
        nList = nMin:nMax;
        [nodeA, nodeB] = ndgrid(nList, nList);
        keep = nodeB(:)>nodeA(:);
        nodeA = nodeA(keep);
        nodeB = nodeB(keep);
        if(~isempty(nodeA))
          edgeList = tom.GraphEdge(nodeA, nodeB);
        end
      end
    end
    
    function cost = computeEdgeCost(this, x, graphEdge)     
      nodeA = graphEdge.first;
      nodeB = graphEdge.second;
      
      % return 0 if the specified edge is not found in the graph
%       isAdjacent = ((nodeA+uint32(1))==nodeB) && ...
%         this.tracker.hasData() && ...
%         (nodeA>=this.tracker.first()) && ...
%         (nodeB<=this.tracker.last());
      isAdjacent = (nodeA<nodeB) && ...
        this.tracker.hasData() && ...
        (nodeA>=this.tracker.first()) && ...
        (nodeB<=this.tracker.last());
      if(~isAdjacent)
        cost = 0;
        return;
      end
      
      % return NaN if the graph edge extends outside of the trajectory domain
      tA = this.tracker.getTime(nodeA);
      tB = this.tracker.getTime(nodeB);
      interval = x.domain();
      if(tA<interval.first)
        cost = NaN;
        return;
      end
      
      poseA = x.evaluate(tA);
      poseB = x.evaluate(tB);
      [rayA, rayB] = this.tracker.findMatches(nodeA, nodeB);
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

function cost=computeCost2(poseA, poseB, rayA, rayB, deviation)
  data = edgeCache(nodeA, nodeB, this);
  u = transpose(data.pixB(:, 1)-data.pixA(:, 1));
  v = transpose(data.pixB(:, 2)-data.pixA(:, 2));
  Ea = Quat2Euler(poseA.q);
  Eb = Quat2Euler(poseB.q);
  translation = [poseB.p(1)-poseA.p(1);
    poseB.p(2)-poseA.p(2);
    poseB.p(3)-poseA.p(3)];
  rotation = [Eb(1)-Ea(1);
    Eb(2)-Ea(2);
    Eb(3)-Ea(3)];
  [uvr, uvt] = generateFlowSparse(this, translation, rotation, transpose(data.pixA), nodeA);
 
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
% Pixel coordinate interpretation:
%   @see antbed.CameraArray.projection
% Algorithm is based on:
%   http://code.google.com/p/functionalnavigation/wiki/MotionInducedOpticalFlow
function [uvr, uvt] = generateFlowSparse(this, deltap, deltaEuler, pix, nA)
  % Put the pixel coordinates through the inverse camera projection to get ray vectors
  c = this.sensor.inverseProjection(pix, nA);

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
  pix_new = this.sensor.projection(c_new, nA);

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
  pix_new = this.sensor.projection(c_new, nA);

  % The translational flow field is the pixel coordinate difference
  uvt = pix_new-pix;
  
  % Convert NaN to zero
  uvt(isnan(uvt(:))) = 0;
end

% Converts a set of quaternions to a set of Euler angles
%
% INPUT
% Q = body orientation states in quaternion <scalar,vector> form (4-by-N)
%
% OUTPUT
% E = Euler angles, in the order forward-right-down (4-by-N)
function E=Quat2Euler(Q)
  N=size(Q,2);
  Q=QuatNorm(Q);

  q1=Q(1,:);
  q2=Q(2,:);
  q3=Q(3,:);
  q4=Q(4,:);

  q11=q1.*q1;
  q22=q2.*q2;
  q33=q3.*q3;
  q44=q4.*q4;

  q12=q1.*q2;
  q23=q2.*q3;
  q34=q3.*q4;
  q14=q1.*q4;
  q13=q1.*q3;
  q24=q2.*q4;

  E=zeros(3,N);
  E(1,:)=atan2(2*(q34+q12),q11-q22-q33+q44);
  E(2,:)=real(asin(-2*(q24-q13)));
  E(3,:)=atan2(2*(q23+q14),q11+q22-q33-q44);
end

% Normalize each quaternion to have unit magnitude and positive first element
%
% INPUT/OUTPUT
% Q = quaternions (4-by-n)
function Q = QuatNorm(Q)
  % extract elements
  q1 = Q(1, :);
  q2 = Q(2, :);
  q3 = Q(3, :);
  q4 = Q(4, :);

  % normalization factor
  n = sqrt(q1.*q1+q2.*q2+q3.*q3+q4.*q4);

  % handle negative first element and zero denominator
  s = sign(q1);
  s(s==0) = 1;
  ns = n.*s;
  
  % normalize
  Q(1, :) = q1./ns;
  Q(2, :) = q2./ns;
  Q(3, :) = q3./ns;
  Q(4, :) = q4./ns;
end
