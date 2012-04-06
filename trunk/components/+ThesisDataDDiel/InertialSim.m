classdef InertialSim < antbed.InertialSixDoF
  
  properties (Constant = true, GetAccess = private)
    pFrame=[0; 0; 0];
    qFrame=[1; 0; 0; 0];
  end
  
  properties (SetAccess = private, GetAccess = private)
    na
    nb
    tn
    secondsPerRefresh
    refreshCount
    gyro
    accel
    stats
  end
  
  methods (Access = public, Static = true)
    function this = InertialSim(initialTime, secondsPerRefresh, localCache)
      this = this@antbed.InertialSixDoF(initialTime);
      this.secondsPerRefresh = secondsPerRefresh;
      [this.tn, this.gyro, this.accel] = ReadIMUdat(localCache, 'inertia.dat');
      this.tn = tom.WorldTime(this.tn+initialTime); % same policy for all sensors
      this.na = uint32(1);
      this.nb = this.na;
      S = load(fullfile(localCache, 'workspace.mat'), 'IMU_TYPE');
      this.stats = IMUModel(S.IMU_TYPE);
      this.refreshCount = uint32(0);
    end
  end
  
  methods (Access = public)
    function refresh(this, x)
      assert(isa(x, 'tom.Trajectory'));
      tMax = this.tn(1)+double(this.refreshCount)*this.secondsPerRefresh;
      nNext = this.nb+uint32(1);
      while((numel(this.tn)>nNext)&&(this.tn(nNext+1)<tMax))
        this.nb = nNext;
        nNext = this.nb+uint32(1);
      end
      this.refreshCount = this.refreshCount+uint32(1);  
    end
    
    function flag = hasData(this)      
      flag = this.refreshCount>uint32(0);
    end
    
    function n = first(this)
      assert(this.hasData());
      n = this.na;
    end

    function n = last(this)
      assert(this.hasData());
      n = this.nb;
    end
    
    function time = getTime(this, n)
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      time = this.tn(n-this.na+uint32(1));
    end
    
    function pose = getFrame(this)
      pose.p = this.pFrame;
      pose.q = this.qFrame;
      pose = tom.Pose(pose);
    end

    function specificForce = getSpecificForce(this, n, ax)
      assert(this.hasData());
      assert(n>=this.na);
      assert(n<=this.nb);
      specificForce = this.accel(ax+1, n);
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
      assert(n>=this.na);
      assert(n<=this.nb);
      angularRate = this.gyro(ax+1, n);
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

% Reads inertial state files that were written by WriteIMUdat()
%
% INPUT
% path = directory for inertial data
% imufile = data file name
% 
% OUTPUT
% time = time stamp vector (1-by-(n+1))
% gyro = gyroscope output (3-by-n)
% accel = accelerometer output (3-by-n)
function [time, gyro, accel] = ReadIMUdat(path, imufile)
  fn = fullfile(path, imufile);
  [a, b, c, d, e, f, g]=textread(fn, '%f\t%f\t%f\t%f\t%f\t%f\t%f');
  time = a';
  gyro = [b'; c'; d'];
  accel = [e'; f'; g'];
end

% DESCRIPTION
%   Implements a lookup table for inertial sensor noise parameters.
%   Each model is defined by the STANDARD DEVIATION of its component errors.
%
% ARGUMENT
%   model = IMU_TYPE or model number ('Ideal','MMIMU','LN200','LN100','ADXL103')
%
% RETURN
%   stats = structure containing model parameters
function stats = IMUModel(model)

switch model

case 'Ideal'
  Gyro.Bias.TurnOn = 0; % radian/sec
  Gyro.Bias.SteadyState = 0; % radian/sec
  Gyro.Bias.Decay = Inf; % sec 
  Gyro.Scale.TurnOn = 0; % parts
  Gyro.Scale.SteadyState = 0; % part
  Gyro.Scale.Decay = Inf; % sec
  Gyro.RandomWalk = 0; % radians/sqrt(sec)

  Accel.Bias.TurnOn = 0; % meters/sec^2
  Accel.Bias.SteadyState = 0; % meters/sec^2
  Accel.Bias.Decay = Inf; % sec
  Accel.Scale.TurnOn = 0; % parts
  Accel.Scale.SteadyState = 0; % parts
  Accel.Scale.Decay = Inf; % sec
  Accel.RandomWalk = 0; % meters/sec/sqrt(sec)

case 'RandomWalkOnly'
  Gyro.Bias.TurnOn = 0; % radian/sec
  Gyro.Bias.SteadyState = 0; % radian/sec
  Gyro.Bias.Decay = Inf; % sec 
  Gyro.Scale.TurnOn = 0; % parts
  Gyro.Scale.SteadyState = 0; % part
  Gyro.Scale.Decay = Inf; % sec
  Gyro.RandomWalk = 1E-3; % radians/sqrt(sec)

  Accel.Bias.TurnOn = 0; % meters/sec^2
  Accel.Bias.SteadyState = 0; % meters/sec^2
  Accel.Bias.Decay = Inf; % sec
  Accel.Scale.TurnOn = 0; % parts
  Accel.Scale.SteadyState = 0; % parts
  Accel.Scale.Decay = Inf; % sec
  Accel.RandomWalk = 1E-2; % meters/sec/sqrt(sec)

case 'MMIMU'
  Gyro.Bias.TurnOn = (pi/180/3600)*3; % radian/sec
  Gyro.Bias.SteadyState = (pi/180/3600)*5; % radian/sec
  Gyro.Bias.Decay = 100; % sec 
  Gyro.Scale.TurnOn = (1E-6)*70; % parts
  Gyro.Scale.SteadyState = (1E-6)*100; % parts
  Gyro.Scale.Decay = 100; % sec
  Gyro.RandomWalk = (pi/180/sqrt(3600))*0.05; % radians/sqrt(sec)

  Accel.Bias.TurnOn = (9.8E-3)*2; % meters/sec^2
  Accel.Bias.SteadyState = (9.8E-3)*1; % meters/sec^2
  Accel.Bias.Decay = 60; % sec
  Accel.Scale.TurnOn = (1E-6)*125; % parts
  Accel.Scale.SteadyState = (1E-6)*600; % parts
  Accel.Scale.Decay = 60; % sec
  Accel.RandomWalk = (1/sqrt(3600))*0.02; % meters/sec/sqrt(sec)

case 'LN200'
  Gyro.Bias.TurnOn = (pi/180/3600)*1; % radian/sec
  Gyro.Bias.SteadyState = (pi/180/3600)*0.35; % radian/sec
  Gyro.Bias.Decay = 100; % sec 
  Gyro.Scale.TurnOn = (1E-6)*100; % parts
  Gyro.Scale.SteadyState = 0; % parts
  Gyro.Scale.Decay = Inf; % sec
  Gyro.RandomWalk = (pi/180/sqrt(3600))*0.07; % radians/sqrt(sec)

  Accel.Bias.TurnOn = (9.8E-3)*0.2; % meters/sec^2
  Accel.Bias.SteadyState = (9.8E-3)*0.05; % meters/sec^2
  Accel.Bias.Decay = 60; % sec
  Accel.Scale.TurnOn = (1E-6)*300; % parts
  Accel.Scale.SteadyState = 0; % parts
  Accel.Scale.Decay = Inf; % sec
  Accel.RandomWalk = (1/sqrt(3600))*0.03; % meters/sec/sqrt(sec)

case 'LN200real'
  stats = IMUModel('LN200');
  return;

case 'LN100'
  Gyro.Bias.TurnOn = (pi/180/3600)*0.003; % radian/sec
  Gyro.Bias.SteadyState = (pi/180/3600)*0.003; % radian/sec
  Gyro.Bias.Decay = 100; % sec 
  Gyro.Scale.TurnOn = (1E-6)*5; % parts
  Gyro.Scale.SteadyState = 0; % parts
  Gyro.Scale.Decay = Inf; % sec
  Gyro.RandomWalk = (pi/180/sqrt(3600))*0.001; % radians/sqrt(sec)

  Accel.Bias.TurnOn = (9.8E-3)*0.025; % meters/sec^2
  Accel.Bias.SteadyState = (9.8E-3)*0.01; % meters/sec^2
  Accel.Bias.Decay = 60; % sec
  Accel.Scale.TurnOn = (1E-6)*5; % parts
  Accel.Scale.SteadyState = 0; % parts
  Accel.Scale.Decay = Inf; % sec
  Accel.RandomWalk = (1/sqrt(3600))*0.003; % meters/sec/sqrt(sec)

case 'ADXL103'
  Gyro.Bias.TurnOn = (pi/180/3600)*200; % radian/sec
  Gyro.Bias.SteadyState = (pi/180/3600)*200; % radian/sec
  Gyro.Bias.Decay = 100; % sec 
  Gyro.Scale.TurnOn = (1E-6)*1000; % parts
  Gyro.Scale.SteadyState = (1E-6)*1000; % parts
  Gyro.Scale.Decay = 100; % sec
  Gyro.RandomWalk = (pi/180/sqrt(3600))*3; % radians/sqrt(sec)

  Accel.Bias.TurnOn = (9.8E-3)*25; % meters/sec^2
  Accel.Bias.SteadyState = (9.8E-3)*3.3; % meters/sec^2
  Accel.Bias.Decay = 60; % sec
  Accel.Scale.TurnOn = (1E-6)*3000; % parts
  Accel.Scale.SteadyState = (1E-6)*3000; % parts
  Accel.Scale.Decay = 60; % sec
  Accel.RandomWalk = (1/sqrt(3600))*0.09; % meters/sec/sqrt(sec)

otherwise
  error('invalid IMU_TYPE');
  
end

% store component statistics in the output structure
stats.Gyro = Gyro;
stats.Accel = Accel;

end
