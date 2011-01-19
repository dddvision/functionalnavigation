classdef InertialTDMSim < tom.DynamicModel & InertialTDMSim.InertialTDMSimConfig

  properties (Constant = true, GetAccess = private)
    nIL = uint32(0);
    nIU = uint32(0);
    nEL = uint32(0);
    nEU = uint32(6);
    numStates = uint32(13);
    numData = uint32(8);
    errorText = 'This dynamic model has no initial parameters or logical extension parameters';
  end
  
  properties (Access = protected)
    initialTime % lower bound of the trajectory domain
    finalTime % upper bound of the trajectory domain
    uri % data source containing a reference trajectory
    nEB % number of extension blocks
    firstNewBlock % one-based index of first parameter block that has not been integrated
    xi % initial body state offset [p; q; r; s]
    x % body state without initial offset [p; q; r; s]
    u % data [accelerometer; gyroscope; accelerometer sigma; gyroscope sigma]
    vi % initial parameters [accelerometer; gyroscope]
    v % extension parameterr [accelerometer; gyroscope]
    imu % singleton IMU sensor instance
    aSigma % accelerometer sigma
    gSigma % gyroscop sigma
    xRef % reference trajectory representing ground truth
  end
  
  methods (Static = true, Access = public)
    function initialize(name)
      function text = componentDescription
        text = 'Represents parametrically corrected strapdown integration model.';
      end
      tom.DynamicModel.connect(name, @componentDescription, @InertialTDMSim.InertialTDMSim);
    end
  end
  
  methods (Access = public)
    function this = InertialTDMSim(initialTime, uri)
      this = this@tom.DynamicModel(initialTime, uri);
      this.initialTime = initialTime;
      this.finalTime = initialTime;
      this.uri = uri;
      this.nEB = uint32(0);
      this.firstNewBlock = uint32(1);
      this.x = zeros(this.numStates, 1);
      this.u = zeros(this.numData, 1);
      this.vi = zeros(this.nIU, 1, 'uint32');
      this.v = zeros(this.nEU, 1, 'uint32');
      
      if(~strncmp(uri, 'antbed:', 7))
        error('URI scheme not recognized. This simulator requires a reference trajectory.');
      end
      container = antbed.DataContainer.create(uri(8:end), initialTime);
      if(hasReferenceTrajectory(container))
        this.xRef = getReferenceTrajectory(container);
      else
        this.xRef = tom.DynamicModelDefault(initialTime, uri);
      end
      
      xt = this.xRef.tangent(initialTime);
      this.xi = [xt.p; xt.q; xt.r; xt.s];
      
      this.imu = InertialTDMSim.InertialSim(initialTime, InertialTDMSim.IMUModel(this.model));
      this.aSigma = this.imu.getAccelRandomWalk();
      this.gSigma = this.imu.getGyroRandomWalk();      
    end
    
    function interval = domain(this)
      interval = tom.TimeInterval(this.initialTime, this.finalTime);
    end
    
   function pose = evaluate(this, t)
      N = numel(t);
      if(N==0)
        pose = repmat(tom.Pose, [1, N]);
      else
        pose(1, N) = tom.Pose;
        interval = this.domain();
        lowerBound = t>=interval.first;
        upperBound = t<=interval.second;
        for n = find(lowerBound)
          if(upperBound(n))
            xt = this.subIntegrate(t(n));
            pose(n).p = xt(1:3);
            pose(n).q = xt(4:7);
          else
            finalTangentPose = this.tangent(interval.second);
            pose(n) = predictPose(finalTangentPose, t(n)-interval.second);
          end
        end
      end
    end

    function tangentPose = tangent(this, t)
      N = numel(t);
      if(N==0)
        tangentPose = repmat(tom.TangentPose, [1, 0]);
      else
        tangentPose(1, N) = tom.TangentPose;
        interval = this.domain();
        lowerBound = t>=interval.first;
        upperBound = t<=interval.second;
        for n = find(lowerBound)
          if(upperBound(n))
            xt = this.subIntegrate(t(n));
            tangentPose(n).p = xt(1:3);
            tangentPose(n).q = xt(4:7);
            tangentPose(n).r = xt(8:10);
            tangentPose(n).s = xt(11:13);
          else
            finalTangentPose = this.tangent(interval.second);
            tangentPose(n) = predictTangentPose(finalTangentPose, t(n)-interval.second);
          end
        end
      end
    end
    
    function num = numInitialLogical(this)
      num = this.nIL;
    end

    function num = numInitialUint32(this)
      num = this.nIU;
    end

    function num = numExtensionLogical(this)
      num = this.nEL;
    end

    function num = numExtensionUint32(this)
      num = this.nEU;
    end

    function num = numExtensionBlocks(this)
      num = this.nEB;
    end

    function vp = getInitialLogical(this, p)
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      vp = false;
      error(this.errorText);
    end

    function vp = getInitialUint32(this, p)
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      vp = uint32(0);
      error(this.errorText);
    end

    function vbp = getExtensionLogical(this, b, p)
      assert(isa(b, 'uint32'));
      assert(numel(b)==1);
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      vbp = false;
      error(this.errorText);
    end

    function vbp = getExtensionUint32(this, b, p)
      assert(b<this.nEB);
      assert(p<this.nEU);
      vbp = this.v(p+1, b+1);
    end

    function setInitialLogical(this, p, vp)
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      assert(isa(vp, 'logical'));
      assert(numel(vp)==1);
      error(this.errorText);
    end

    function setInitialUint32(this, p, vp)        
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      assert(isa(vp, 'uint32'));
      assert(numel(vp)==1);
      error(this.errorText);
    end

    function setExtensionLogical(this, b, p, vbp)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p, 'uint32'));
      assert(numel(p)==1);
      assert(isa(vbp, 'logical'));
      assert(numel(vbp)==1);
      error(this.errorText);
    end

    function setExtensionUint32(this, b, p, vbp)
      assert(b<this.nEB);
      assert(p<this.nEU);
      this.v(p+1, b+1) = vbp;
      this.firstNewBlock = min(this.firstNewBlock, b+1);
    end

    function cost = computeInitialBlockCost(this)
      z = block2deviation(this.vi);
      cost = 0.5*(z'*z);
    end

    function cost = computeExtensionBlockCost(this, b)
      z = block2deviation(this.v(:, b+1));
      cost = 0.5*(z'*z);
    end

    function extend(this)
      this.nEB = this.nEB+uint32(1);
      B = this.nEB;
      N = size(this.x, 2);
      if((~this.imu.hasData())||(B>this.imu.last()))
        this.imu.refresh(this.xRef);
      end
      if(B>N)
        this.x = cat(2, this.x, zeros(this.numStates, N));
        this.u = cat(2, this.u, zeros(this.numData, N));
        this.v = cat(2, this.v, zeros(this.nEU, N, 'uint32'));
      end
      this.u(:, B) = [this.imu.getSpecificForce(B, uint32(0));
        this.imu.getSpecificForce(B, uint32(1));
        this.imu.getSpecificForce(B, uint32(2));
        this.imu.getAngularRate(B, uint32(0));
        this.imu.getAngularRate(B, uint32(1));
        this.imu.getAngularRate(B, uint32(2))
        this.aSigma;
        this.gSigma];
      this.finalTime = this.imu.getTime(B);
    end

    function obj = copy(this)
      obj = InertialTDMSim.InertialTDMSim(this.initialTime, this.uri);
      mc = metaclass(this);
      prop = mc.Properties;
      for p = 1:numel(prop)
        if(~prop{p}.Constant)
          obj.(prop{p}.Name) = this.(prop{p}.Name);
        end
      end
    end
  end
  
  methods (Access = private)
    function xt = subIntegrate(this, t)
      bb = (t-this.initialTime)/this.tau;
      b = ceil(bb); % not equal to floor(bb)+1
      dt = (bb-b+1)*this.tau;
      if(b==0)
        xbm = this.xi;
        dt = 0;
        b = b+1;
      elseif(b==1)
        xbm = this.xi;
      else
        this.blockIntegrate(b-1);
        xbm = this.x(:, b-1);
      end
      xt = F(xbm, this.u(:, b), this.v(:, b), dt);  
    end
    
    % Integrate up to and including block B with one-based indexing
    function blockIntegrate(this, B)
      for b = this.firstNewBlock:B
        if(b==1)
          xbm = this.xi;
        else
          xbm = this.x(:, b-1);
        end
        this.x(:, b) = F(xbm, this.u(:, b), this.v(:, b), this.tau);
      end
      this.firstNewBlock = max(this.firstNewBlock, B+uint32(1));
    end
  end
  
end

% x(1:3) = position 
% x(4:7) = quaternion
% x(8:10) = position rate
% x(11:13) = rotation rate
% u(1:3) = accelerometer data
% u(4:6) = gyroscope data
% u(7) = accelerometer sigma
% u(8) = gyroscope sigma
% v(1:3) = accelerometer correction parameters
% v(4:6) = gyroscope correction parameters
function xp = F(xm, u, v, dt)
  aCorrected = u(1:3)-u(7)*block2deviation(v(1:3));
  gCorrected = u(4:6)-u(8)*block2deviation(v(4:6));
  deltaV = Quat2Matrix(xm(4:7))*(dt*aCorrected);
  xp = [xm(1:3)+dt*xm(8:10)+0.5*dt*deltaV;
    Quat2Homo(xm(4:7))*AxisAngle2Quat(dt*gCorrected);
    xm(8:10)+deltaV;
    2*gCorrected];
end

function z = block2deviation(block)
  sixthIntMax = 715827882.5;
  z = double(block)/sixthIntMax-3;
end

function pose = predictPose(tP, dt)
  N = numel(dt);
  if(N==0)
    pose = repmat(tom.Pose, [1, 0]);
    return;
  end

  p = tP.p*ones(1, N)+tP.r*dt;
  dq = AxisAngle2Quat(tP.s*dt);
  q = Quat2HomoReverse(tP.q)*dq; % dq*q
  
  pose(1, N) = tom.Pose;
  for n = 1:N
    pose(n).p = p(:, n);
    pose(n).q = q(:, n);
  end
end

function tangentPose = predictTangentPose(tP, dt)
  N = numel(dt);
  if(N==0)
    tangentPose = repmat(tom.TangentPose, [1, 0]);
    return;
  end

  p = tP.p*ones(1, N)+tP.r*dt;
  dq = AxisAngle2Quat(tP.s*dt); 
  q = Quat2HomoReverse(tP.q)*dq; % dq*q

  tangentPose(1, N) = tP;
  for n = 1:N
    tangentPose(n).p = p(:, n);
    tangentPose(n).q = q(:, n);
    tangentPose(n).r = tP.r;
    tangentPose(n).s = tP.s;
  end
end

function h = Quat2HomoReverse(q)
  q1 = q(1);
  q2 = q(2);
  q3 = q(3);
  q4 = q(4);
  h = [[q1, -q2, -q3, -q4]
       [q2,  q1,  q4, -q3]
       [q3, -q4,  q1,  q2]
       [q4,  q3, -q2,  q1]];
end

function h = Quat2Homo(q)
  q1 = q(1);
  q2 = q(2);
  q3 = q(3);
  q4 = q(4);
  h = [[q1, -q2, -q3, -q4]
       [q2,  q1, -q4,  q3]
       [q3,  q4,  q1, -q2]
       [q4, -q3,  q2,  q1]];
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
