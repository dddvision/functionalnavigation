classdef measure
  
  methods (Access=public,Abstract=true)
    % Evaluate a measure of inconsistency between a trajectory and sensor data
    %
    % INPUTS
    % x = trajectory object
    % tmin = time domain lower bound over which to evaluate, double scalar
    %
    % OUTPUT
    % cost = non-negative value of inconsistency, double scalar
    %
    % NOTE
    % The input trajectory objects represent the motion of the body frame
    % relative to a world frame.  If the sensor frame is not coincident with
    % the body frame, then transformations may be necessary.
    cost=evaluate(this,x,tmin);
  end
  
end
