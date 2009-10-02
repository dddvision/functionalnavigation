% NOTES
% This class defines a synchronously time-stamped group of inertial sensors
%   rigidly attached to a body with different positions and orientations
% The body frame axis order is forward-right-down
classdef inertial < sensor

  methods (Abstract)
    % Get number of axes in the group
    %
    % OUTPUT
    % num = number of axes, uint32 N-by-1
    num=numAxes(this);

    % Get inertial integration time
    %
    % OUTPUT
    % dt = time period, double scalar
    %
    % NOTES
    % This value is not guaranteed to match the difference between
    %   the time stamps of consecutively indexed data
    dt=getIntegrationTime(this);
    
    % Get axis position and orientation relative to the body frame
    %
    % INPUT
    % ax = zero-based axis index, uint32 scalar
    %
    % OUTPUT
    % offset = position and unit normalized direction vector, double 6-by-1
    offset=getOffset(this,ax);
  end
  
end
