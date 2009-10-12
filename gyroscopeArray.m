% This class defines how to access data from a gyroscope
% If you need to add optional device methods, then inherit from this class
classdef gyroscopeArray < inertialArray
  
  methods (Abstract=true)
    % Get raw gyroscope data
    %
    % INPUT
    % k = data index, uint32 scalar
    % ax = zero-based axis index, uint32 scalar
    %
    % OUTPUT
    % angularRate = average angular rate during the preceding integration period, double scalar
    %
    % NOTES
    % Average angular rate is a raw measurement from a typical integrating gyroscope
    % This measurement is taken by integrating about the instantaneous
    %   axis as it moves during the preceding time step
    angularRate=getAngularRate(this,k,ax);
    
    % TODO: add error model
    
  end
  
end
