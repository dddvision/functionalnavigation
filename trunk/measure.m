% This class defines a graph of measures between sensor data and a trajectory
classdef measure
  
  properties (Constant=true,GetAccess=public)
    baseClass='measure';
  end
  
  methods (Access=protected)
    % Construct a measure given a sensor and a trajectory
    %
    % INPUT
    % u = sensor instance
    % x = trajectory instance
    %
    % NOTES
    % A subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@measure(u,x);
    function this=measure(u,x)
      assert(isa(u,'sensor'));
      assert(isa(x,'trajectory'));
    end
  end
  
  methods (Abstract=true)
    % Set the trajectory that will be used to compute costs
    %
    % INPUT
    % x = trajectory instance
    this=setTrajectory(this,x);
    
    % Find all edges in the adjacency graph
    %
    % OUTPUT
    % a = lower node index for each edge, uint32 N-by-1
    % b = upper node index for each edge, uint32 N-by-1
    %
    % NOTES
    % Indices must be sorted in ascending order, first by lower then by upper
    [a,b]=findEdges(this);
    
    % Evaluate a measure of an edge
    %
    % INPUTS
    % a = lower node index, uint32 scalar
    % b = upper node index, uint32 scalar
    %
    % OUTPUT
    % cost = non-negative measure in the interval [0,1], double scalar
    %
    % NOTES
    % A trajectory represents the motion of the body frame relative to a 
    % world frame. If the sensor frame is not coincident with the body 
    % frame, then the sensor frame offset may need to be kinematically 
    % composed with the body frame to locate the sensor.
    cost=computeEdgeCost(this,a,b);
  end
  
end
