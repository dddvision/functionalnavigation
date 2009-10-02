% NOTES
% If you need to add optional device methods, then inherit from this class
classdef gyroscope < inertial
  
  methods (Abstract=true)
    % Get raw gyroscope data
    %
    % INPUT
    % ax = zero-based axis index, uint32 scalar
    % k = data index, uint32 scalar
    %
    % OUTPUT
    % angularRate = average angular rate during the preceeding integration period, double scalar
    %
    % NOTES
    % Average angular rate is a raw measurement from a typical integrating gyroscope
    % This measurement is taken about the direction of the axis at the 
    %   beginning of the preceeding time step using the right-hand-rule
    angularRate=getAngularRate(this,ax,k);
  end
  
end
