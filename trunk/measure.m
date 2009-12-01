% This class defines a graph of measures between sensor data and a trajectory
classdef measure
  
  properties (Constant=true,GetAccess=public)
    baseClass='measure';
  end
  
  properties (SetAccess=private,GetAccess=protected)
     sensor
     trajectory
  end
  
  methods (Access=protected)
    % Construct a measure given a sensor and a trajectory
    %
    % INPUT
    % u = sensor object
    % x = trajectory object
    %
    % NOTE
    % A subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@measure(u,x);
    % The input trajectory object represents the motion of the body frame
    % relative to a world frame. If the sensor frame is not coincident with
    % the body frame, then the sensor frame offset may need to be 
    % kinematically composed with the body frame to locate the sensor.
    function this=measure(u,x)
      if(nargin~=0)
        this.sensor=u;
        this.trajectory=x;
      end
    end
  end
  
  methods (Abstract=true)
    % Find all edges in the adjacency graph
    %
    % OUTPUT
    % a = lower node index for each edge, uint32 N-by-1
    % b = upper node index for each edge, uint32 N-by-1
    %
    % NOTE
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
    cost=computeEdgeCost(this,a,b);
  end
  
  methods (Access=public)
    function this=setTrajectory(this,x)
      this.trajectory=x;
    end
  end
  
end
