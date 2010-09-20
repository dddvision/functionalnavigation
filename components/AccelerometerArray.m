% This class defines how to access data from an accelerometer
classdef AccelerometerArray < InertialArray
  
  methods (Abstract=true)
    % Get raw accelerometer data
    %
    % INPUT
    % n = data index, uint32 scalar
    % ax = zero-based axis index, uint32 scalar
    %
    % OUTPUT
    % specificForce = average specific force during the preceding integration period, double scalar
    %
    % NOTES
    % Specific force is a raw measurement from a typical integrating accelerometer
    % This measurement has not been gravity compensated
    % This measurement is taken by integrating about the instantaneous
    %   axis as it moves during the preceding time step
    %
    % NOTES
    % Throws an exception if either input index is out of range
    specificForce=getSpecificForce(this,n,ax);
    
    % Get sensor error model in terms of MKS units and 1-sigma deviations
    sigma=getAccelBiasTurnOn(this); % meters/sec^2
    sigma=getAccelBiasSteadyState(this); % meters/sec^2
    tau=getAccelBiasDecay(this); % sec
    sigma=getAccelScaleTurnOn(this); % unitless
    sigma=getAccelScaleSteadyState(this); % unitless
    tau=getAccelScaleDecay(this); % sec
    sigma=getAccelRandomWalk(this); % meters/sec/sqrt(sec)  
  end
  
end
