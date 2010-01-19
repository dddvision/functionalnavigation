% This class defines a graph of measures between sensor data and a trajectory
classdef measure < handle
  
  properties (Constant=true,GetAccess=public)
    baseClass='measure';
  end
  
  methods (Access=protected)
    % Construct a measure
    %
    % INPUT
    % uri = uniform resource identifier, string
    %
    % NOTES
    % The URI should identify a hardware resource or dataContainer
    % URI examples:
    %   'file://dev/camera0'
    %   'matlab:middleburyData.middleburyData'
    % A subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@measure(uri);
    function this=measure(uri)
      assert(isa(uri,'char'));
    end
  end
  
  methods (Abstract=true)
    % Incorporate new data and allow old data to expire
    %
    % OUTPUT
    % status = true if any data is available and false otherwise, logical scalar
    %
    % NOTES
    % Does not wait for hardware events
    status=refresh(this);
    
    % Get time stamp at a node
    %
    % INPUT
    % k = data index, uint32 scalar
    %
    % OUTPUT
    % time = time stamp, double scalar
    %
    % NOTES
    % Time stamps must not decrease with increasing indices
    % Throws an exception if data index is invalid
    time=getTime(this,k);
    
    % Check whether the adjacency matrix of the graph is diagonal
    %
    % OUTPUT
    % flag = true if no edges span more than one node and false otherwise, logical scalar
    flag=isDiagonal(this);
    
    % Find all edges in the graph and list the nodes that they connect
    %
    % OUTPUT
    % ka = lower node index for each edge, uint32 N-by-1
    % kb = upper node index for each edge, uint32 N-by-1
    %
    % NOTES
    % If there are no edges, then the outputs are empty
    % Indices must be sorted in ascending order, first by a then by b
    % If graph is diagonal, then a and b are identical
    [ka,kb]=findEdges(this);
    
    % Evaluate the cost of edge
    %
    % INPUT
    % x = trajectory instance
    % ka = lower node index, uint32 scalar
    % kb = upper node index, uint32 scalar
    %
    % OUTPUT
    % cost = non-negative measure in the interval [0,1], double scalar
    %
    % NOTES
    % The input trajectory represents the motion of the body frame relative 
    %   to a world frame. If the sensor frame is not coincident with the 
    %   body frame, then the sensor frame offset may need to be 
    %   kinematically composed with the body frame to locate the sensor
    % Throws an exception if either node index is invalid
    cost=computeEdgeCost(this,x,ka,kb);
  end
  
end
