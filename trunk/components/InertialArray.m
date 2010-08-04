% This class defines a synchronously time-stamped array of inertial sensors
%   rigidly attached to a body with different positions and orientations
classdef InertialArray < Sensor

  methods (Abstract)
    % Get number of axes in the array
    %
    % OUTPUT
    % num = number of axes, uint32 scalar
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
