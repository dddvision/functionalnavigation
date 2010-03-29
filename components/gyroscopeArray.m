% This class defines how to access data from a gyroscope
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
    %
    % NOTES
    % Throws an exception if either input index is out of range
    angularRate=getAngularRate(this,k,ax);
  end
  
end
