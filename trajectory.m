% This class defines a 6-DOF body trajectory in the vicinity of Earth
classdef trajectory
  
  methods (Abstract=true)
    % Return the upper and lower bounds of the time domain of a trajectory
    %
    % OUTPUT
    % a = time domain lower bound, double scalar
    % b = time domain upper bound, double scalar
    [a,b]=domain(this);
    
    % Evaluate a single trajectory at multiple time instants
    %
    % INPUT
    % t = time, 1-by-N
    %
    % OUTPUT
    % lonLatAlt = body position at each time, double 3-by-N
    % quaternion = body orientation at each time, double 4-by-N
    %
    % NOTE
    % Using SI units (seconds, meters, radians)
    % The origin is at the equatorial meridian on the surface of the WGS84 
    %   ellipsoid with the body axes aligned with east-north-up
    % Quaternions are in scalar-first format
    % Evaluation outside of the domain returns NaN in corresponding columns
    [lonLatAlt,quaternion]=evaluate(this,t);
    
    % Evaluate time derivative of a single trajectory at multiple time instants
    %
    % INPUT
    % t = time, 1-by-N
    %
    % OUTPUT
    % lonLatAltRate = derivative of body position at each time, double 3-by-N
    % quaternionRate = derivative of body orientation at each time, double 4-by-N
    [lonLatAltRate,quaternionRate]=derivative(this,t);
  end
  
end
