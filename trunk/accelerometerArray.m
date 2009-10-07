% NOTES
% If you need to add optional device methods, then inherit from this class
classdef accelerometerArray < inertialElement
  
  methods (Abstract=true)
    % Get raw accelerometer data
    %
    % INPUT
    % k = data index, uint32 scalar
    % ax = zero-based axis index, uint32 scalar
    %
    % OUTPUT
    % specificForce = average specific force during the preceeding integration period, double scalar
    %
    % NOTES
    % Specific force is a raw measurement from a typical integrating accelerometer
    % This measurement has not been gravity compensated
    % This measurement is taken by integrating about the instantaneous
    %   axis as it moves during the preceeding time step
    specificForce=getSpecificForce(this,k,ax);
  end
  
end
