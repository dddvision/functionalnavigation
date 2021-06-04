% DESCRIPTION
%   Implements a lookup table for inertial sensor noise parameters.
%   Each model is defined by the STANDARD DEVIATION of its component errors.
%
% ARGUMENT
%   model = IMU_TYPE or model number ('Ideal','MMIMU','LN200','LN100','ADXL103')
%
% RETURN
%   stats = structure containing model parameters
% Public Domain
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
