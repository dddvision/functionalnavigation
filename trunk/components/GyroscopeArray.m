% This class defines how to access data from a gyroscope
classdef GyroscopeArray < InertialArray
  
  methods (Abstract=true)
    % Get raw gyroscope data
    %
    % INPUT
    % n = data index, uint32 scalar
    % ax = zero-based axis index, uint32 scalar
    %
    % OUTPUT
    % angularRate = average angular rate during the preceding integration period, double scalar
    %
    % NOTES
    % Average angular rate is a raw measurement from a typical integrating gyroscope
    % This measurement is taken by integrating about the instantaneous
    %   axis as it moves during the preceding time step
    %
    % NOTES
    % Throws an exception if either input index is out of range
    angularRate=getAngularRate(this,n,ax);
    
    % Get sensor error model in terms of MKS units and 1-sigma deviations
    sigma=getGyroBiasTurnOn(this); % radian/sec
    sigma=getGyroBiasSteadyState(this); % radian/sec
    tau=getGyroBiasDecay(this); % sec
    sigma=getGyroScaleTurnOn(this); % unitless
    sigma=getGyroScaleSteadyState(this); % unitless
    tau=getGyroScaleDecay(this); % sec
    sigma=getGyroRandomWalk(this); % radians/sqrt(sec)
  end
  
end
