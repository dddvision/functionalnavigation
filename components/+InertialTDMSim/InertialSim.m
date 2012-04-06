% TODO: include gravity
% TODO: include bias and scale errors
% TODO: include sensor offset
classdef InertialSim < hidi.InertialSixDoF & InertialTDMSim.InertialTDMSimConfig
  
  properties (Constant = true)
    nFirst = uint32(1); % first data node index
    pFrame = [0; 0; 0]; % position offset of IMU frame from body frame
    qFrame = [1; 0; 0; 0]; % orientation offset of IMU frame from body frame
  end
  
  properties (Access = private)
    initialTime % time at which the first integration step begins
    aData % accelerometer data based on sensor model and noise
    gData % gyroscope data based on sensor model and noise
    nLast % last data node index
    stats % IMU error statistics
  end
  
  methods (Access = public)
    function this = InertialSim(initialTime, stats)
      persistent singleton
      this = this@hidi.InertialSixDoF(initialTime);
      if(isempty(singleton))
        this.initialTime = initialTime;
        this.nLast = uint32(0);
        this.stats = stats;
        singleton = this;
      else
        this = singleton;
      end
    end
    
    function refresh(this, xRef)
      nData = size(this.aData, 2);
      this.nLast = this.nLast+uint32(1);
      if(this.nLast>nData)
        this.aData = cat(2, this.aData, zeros(3, nData));
        this.gData = cat(2, this.gData, zeros(3, nData));
      end
      tB = this.getTime(this.nLast);
      if(this.nLast==1)
        interval = xRef.domain();
        tA = interval.first;
      else
        tA = tB-this.tau;
      end
      tPA = xRef.tangent(tA);
      tPB = xRef.tangent(tB);
      Minv = Quat2Matrix(QuatConj(tPA.q));
      this.aData(:, this.nLast) = Minv*((tPB.r-tPA.r)/this.tau+this.getAccelRandomWalk()*randn(3, 1));
      this.gData(:, this.nLast) = Quat2AxisAngle(Quat2Homo(QuatConj(tPA.q))*tPB.q)/this.tau+this.getGyroRandomWalk()*randn(3, 1);
    end
    
    function flag = hasData(this)      
      flag = this.nLast>=this.nFirst;
    end
    
    function n = first(this)
      assert(this.hasData());
      n = this.nFirst;
    end

    function n = last(this)
      assert(this.hasData());
      n = this.nLast;
    end
    
    function time = getTime(this, n)
      assert(this.hasData());
      assert(n>=this.nFirst);
      assert(n<=this.nLast);
      time = hidi.WorldTime(this.initialTime+double(this.nLast)*this.tau);
    end
    
    function pose = getFrame(this)
      pose.p = this.pFrame;
      pose.q = this.qFrame;
      pose = tom.Pose(pose);
    end

    function specificForce = getSpecificForce(this, n, ax)
      assert(this.hasData());
      assert(n>=this.nFirst);
      assert(n<=this.nLast);
      specificForce = this.aData(ax+1, n);
    end
    
    function sigma = getAccelBiasTurnOn(this)
      sigma = this.stats.Accel.Bias.TurnOn;
    end
    
    function sigma = getAccelBiasSteadyState(this)
      sigma = this.stats.Accel.Bias.SteadyState;
    end
    
    function tau = getAccelBiasDecay(this)
      tau = this.stats.Accel.Bias.Decay;
    end
    
    function sigma = getAccelScaleTurnOn(this)
      sigma = this.stats.Accel.Scale.TurnOn;
    end
    
    function sigma = getAccelScaleSteadyState(this)
      sigma = this.stats.Accel.Scale.SteadyState;
    end
    
    function tau = getAccelScaleDecay(this)
      tau = this.stats.Accel.Scale.Decay;
    end
    
    function sigma = getAccelRandomWalk(this)
      sigma = this.stats.Accel.RandomWalk;
    end
        
    function angularRate = getAngularRate(this, n, ax)
      assert(this.hasData());
      assert(n>=this.nFirst);
      assert(n<=this.nLast);
      angularRate = this.gData(ax+1, n);
    end
    
    function sigma = getGyroBiasTurnOn(this)
      sigma = this.stats.Gyro.Bias.TurnOn;
    end
    
    function sigma = getGyroBiasSteadyState(this)
      sigma = this.stats.Gyro.Bias.SteadyState;
    end
    
    function tau = getGyroBiasDecay(this)
      tau = this.stats.Gyro.Bias.Decay;
    end
    
    function sigma = getGyroScaleTurnOn(this)
      sigma = this.stats.Gyro.Scale.TurnOn;
    end
    
    function sigma = getGyroScaleSteadyState(this)
      sigma = this.stats.Gyro.Scale.SteadyState;
    end
    
    function tau = getGyroScaleDecay(this)
      tau = this.stats.Gyro.Scale.Decay;
    end
    
    function sigma = getGyroRandomWalk(this)
      sigma = this.stats.Gyro.RandomWalk;
    end      
  end
end

function v = Quat2AxisAngle(q)
  q1 = q(1, :);
  q2 = q(2, :);
  q3 = q(3, :);
  q4 = q(4, :);

  theta = 2*real(acos(q1));
  
  n = sqrt(q2.*q2+q3.*q3+q4.*q4);
  n(n<eps) = eps;
  
  a = q2./n;
  b = q3./n;
  c = q4./n;

  v1 = theta.*a;
  v2 = theta.*b;
  v3 = theta.*c;

  v = [v1; v2; v3];
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

function q = QuatConj(q)
 q(2:4, :) = -q(2:4, :);
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
