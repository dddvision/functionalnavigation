% This class defines a 6-DOF body trajectory in the vicinity of Earth
% Using SI units (seconds, meters, radians)
classdef Trajectory < handle
  
  methods (Abstract=true)
    % Return the upper and lower bounds of the time domain of a trajectory
    %
    % OUTPUT
    % ta = time domain lower bound, double scalar
    % tb = time domain upper bound, double scalar
    [ta,tb]=domain(this);
    
    % Evaluate a single trajectory and its time derivative at multiple instants
    %
    % INPUT
    % t = time stamps sorted in ascending order, 1-by-N
    %
    % OUTPUT
    % position = position of the body frame in ECEF at each time, double 3-by-N
    % rotation = orientation of the body frame as a quaternion at each time, double 4-by-N
    % positionRate = derivative of body position at each time, double 3-by-N
    % rotationRate = derivative of body orientation at each time, double 4-by-N
    %
    % NOTES
    % Using an Earth Centered Earth Fixed (ECEF) convention for the world frame:
    %   World Axis 1 goes through the equator at the prime meridian
    %   World Axis 2 completes the frame using the right-hand-rule
    %   World Axis 3 goes through the north pole
    % Using a Forward-Right-Down (FRD) convention for the body frame:
    %   Body Axis 1 points forward
    %   Body Axis 2 points right
    %   Body Axis 3 points down relative to the body (not gravity)
    % Quaternions are in scalar-first format
    % Evaluation outside of the domain returns NaN in corresponding columns
    [position,rotation,positionRate,rotationRate]=evaluate(this,t);
  end
  
end
