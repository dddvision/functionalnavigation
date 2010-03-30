% This class defines a synchronously time-stamped array of inertial sensors
%   rigidly attached to a body with different positions and orientations
classdef inertialArray < Sensor

  methods (Abstract)
    % Get inertial integration time
    %
    % OUTPUT
    % dt = time period, double scalar
    %
    % NOTES
    % This value is not guaranteed to match the difference between
    %   the time stamps of consecutively indexed data
    dt=getIntegrationTime(this);
    
    % Get number of axes in the array
    %
    % OUTPUT
    % num = number of axes, uint32 N-by-1
    num=numAxes(this);

    % Get axis position and orientation relative to the body frame
    %
    % INPUT
    % ax = zero-based axis index, uint32 scalar
    %
    % OUTPUT
    % offset = position of origin, double 3-by-1
    % direction = unit normalized direction vector, 3-by-1
    %
    % NOTES
    % The body frame axis order is forward-right-down
    % Rotation is measured via the right-hand rule
    % Throws an exception of the input index is out of range
    [offset,direction]=getAxis(this,ax);
  end
  
end
