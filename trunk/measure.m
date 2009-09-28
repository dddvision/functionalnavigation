classdef measure
  
  methods (Access=protected)
    function this=measure
    end
  end
  
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
    
    % Return the upper bound of cost for this measure
    %
    % INPUTS
    % tmin = lower bound of time domain to consider, double scalar
    %
    % OUTPUT
    % costPotential = upper bound of cost for this measure, double scalar
    costPotential=upperBound(this,tmin);
  end
  
end
