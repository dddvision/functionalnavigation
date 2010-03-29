% This class defines how to access data from an accelerometer
classdef accelerometerArray < inertialArray
  
  methods (Abstract=true)
    % Get raw accelerometer data
    %
    % INPUT
    % k = data index, uint32 scalar
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
    specificForce=getSpecificForce(this,k,ax);
  end
  
end
