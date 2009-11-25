% This class defines how a cost measure is applied to a trajectory
classdef measure
  
  properties (Constant=true,GetAccess=public)
    baseClass='measure';
  end
  
  methods (Abstract=true)
    % TODO: Add constructor that accepts a sensor
    
    % Return first and last indices of a consecutive list of nodes
    %
    % OUTPUT
    % a = first valid node index, uint32 scalar
    % b = last valid node index, uint32 scalar
    %
    % NOTES
    % Return values are empty when no nodes are available
    [a,b]=getNodes(this);
    
    % Get node indices in the interval [a,b] that share an edge with node a
    %
    % INPUT
    % a = lower node index, uint32 scalar
    % b = upper node index, uint32 scalar
    %
    % OUTPUT
    % n = indices shared with node a, uint32 N-by-1
    %
    % NOTES
    % Output is sorted in ascending order
    n=getEdgesForward(this,a,b);

    % Get node indices in the interval [a,b] that share an edge with node b
    %
    % INPUT
    % a = lower node index, uint32 scalar
    % b = upper node index, uint32 scalar
    %
    % OUTPUT
    % n = indices shared with node b, uint32 N-by-1
    %
    % NOTES
    % Output is sorted in ascending order
    n=getEdgesBackward(this,a,b);
    
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
    cost=computeEdgeCost(this,x,a,b);
  end
  
end
