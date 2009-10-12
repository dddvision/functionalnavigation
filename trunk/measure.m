% This class defines how a cost measure is applied to a trajectory
classdef measure
  
  properties (Constant=true,GetAccess=public)
    baseClass='measure';
  end
  
  methods (Abstract=true)
    % TODO: Add constructor that accepts camera
      
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
    % the body frame, then the sensor frame offset may need to be 
    % kinematically composed with the body frame to locate the sensor.
    cost=evaluate(this,x,tmin);
  end
  
end
