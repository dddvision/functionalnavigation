% This class defines a graph of measures between sensor data and a trajectory
classdef measure < sensor
  
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
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@measure(uri);
    function this=measure(uri)
      assert(isa(uri,'char'));
    end
  end
  
  methods (Abstract=true)   
    % Find a limited set of edges in the adjacency matrix of the cost graph
    %
    % INPUT
    % kbMin = lower bound of upper node index, uint32 scalar
    % dMax = upper bound of difference between indices, uint32 scalar
    %
    % OUTPUT
    % ka = lower node index for each edge, uint32 N-by-1
    % kb = upper node index for each edge, uint32 N-by-1
    %
    % NOTES
    % The number of edges returned is bounded:
    %   numel(ka) <= (dMax+1)*(last(this)-kbMin+1)
    % If there are no edges, then the outputs are empty
    % Output indices are sorted in ascending order,
    %   first by upper index kb, then by lower index ka
    % If graph is diagonal, then ka and kb are identical
    [ka,kb]=findEdges(this,kbMin,dMax);
    
    % Evaluate the cost of a single edge given a trajectory
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
    % Throws an exception if node indices do not correspond to an edge
    cost=computeEdgeCost(this,x,ka,kb);
  end
  
end
