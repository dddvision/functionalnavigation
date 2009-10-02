% NOTES
% If you need to add optional device methods, then inherit from this class
classdef accelerometer < inertial
  
  methods (Abstract=true)
    % Get raw accelerometer data
    %
    % INPUT
    % ax = zero-based axis index, uint32 scalar
    % k = data index, uint32 scalar
    %
    % OUTPUT
    % specificForce = average specific force during the preceeding integration period, double scalar
    %
    % NOTES
    % Specific force is a raw measurement from a typical integrating accelerometer
    % This measurement has not been gravity compensated
    % This measurement is taken about the direction of the axis at the 
    %   beginning of the preceeding time step
    specificForce=getSpecificForce(this,ax,k);
  end
  
end
