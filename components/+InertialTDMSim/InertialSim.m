% TODO: include gravity
% TODO: include bias and scale errors
% TODO: include sensor offset
% Copyright 2011 Scientific Systems Company Inc., New BSD License
classdef InertialSim < hidi.AccelerometerArray & hidi.GyroscopeArray & InertialTDMSim.InertialTDMSimConfig
  
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
      this = this@hidi.AccelerometerArray();
      this = this@hidi.GyroscopeArray();
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
      Minv = tom.Rotation.quatToMatrix(tom.Rotation.quatInv(tPA.q));
      this.aData(:, this.nLast) = Minv*((tPB.r-tPA.r)/this.tau+this.getAccelerometerRandomWalk()*randn(3, 1));
      this.gData(:, this.nLast) = tom.Rotation.quatToAxis(tom.Rotation.quatMult(tPB.q, tPA.q))/this.tau+...
        this.getGyroscopeRandomWalk()*randn(3, 1);
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
      assert(all(n>=this.nFirst));
      assert(all(n<=this.nLast));
      time = this.initialTime+double(n-this.nFirst)*this.tau;
    end

    function force = getSpecificForce(this, n, ax)
      assert(this.hasData());
      assert(all(n>=this.nFirst));
      assert(all(n<=this.nLast));
      force = this.aData(ax+1, n)';
    end
    
    function force = getSpecificForceCalibrated(this, n, ax)
      force = this.getSpecificForce(this, n, ax);
    end
    
    function walk = getAccelerometerRandomWalk(this)
      walk = this.stats.Accel.RandomWalk;
    end
    
    function sigma = getAccelerometerTurnOnBiasSigma(this)
      sigma = this.stats.Accel.Bias.TurnOn;
    end
    
    function sigma = getAccelerometerInRunBiasSigma(this)
      sigma = this.stats.Accel.Bias.SteadyState;
    end
    
    function tau = getAccelerometerInRunBiasStability(this)
      tau = this.stats.Accel.Bias.Decay;
    end
    
    function sigma = getAccelerometerTurnOnScaleSigma(this)
      sigma = this.stats.Accel.Scale.TurnOn;
    end
    
    function sigma = getAccelerometerInRunScaleSigma(this)
      sigma = this.stats.Accel.Scale.SteadyState;
    end
    
    function tau = getAccelerometerInRunScaleStability(this)
      tau = this.stats.Accel.Scale.Decay;
    end
        
    function rate = getAngularRate(this, n, ax)
      assert(this.hasData());
      assert(all(n>=this.nFirst));
      assert(all(n<=this.nLast));
      rate = this.gData(ax+1, n)';
    end
    
    function rate = getAngularRateCalibrated(this, n, ax)
      rate = getAngularRate(this, n, ax);
    end
    
    function walk = getGyroscopeRandomWalk(this)
      walk = this.stats.Gyro.RandomWalk;
    end
    
    function sigma = getGyroscopeTurnOnBiasSigma(this)
      sigma = this.stats.Gyro.Bias.TurnOn;
    end
    
    function sigma = getGyroscopeInRunBiasSigma(this)
      sigma = this.stats.Gyro.Bias.SteadyState;
    end
    
    function tau = getGyroscopeInRunBiasStability(this)
      tau = this.stats.Gyro.Bias.Decay;
    end
    
    function sigma = getGyroscopeTurnOnScaleSigma(this)
      sigma = this.stats.Gyro.Scale.TurnOn;
    end
    
    function sigma = getGyroscopeInRunScaleSigma(this)
      sigma = this.stats.Gyro.Scale.SteadyState;
    end
    
    function tau = getGyroscopeInRunScaleStability(this)
      tau = this.stats.Gyro.Scale.Decay;
    end
  end
end
