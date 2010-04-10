% This class defines a graph of measures between sensor data and a trajectory
%
% NOTES
% A measure may depend on data from multiple sensors
% Measures do not disclose their sources of information
% Each edge is assumed to be independent, and this means that correlated
%   sensor noise must be modeled and mitigated behind the measure interface
classdef Measure < Sensor

  methods (Static=true,Access=public)
    % Framework class identifier
    %
    % OUTPUT
    % text = name of the framework class, string
    function text=frameworkClass
      text='Measure';
    end
    
    % Public method to construct a Measure
    %
    % INPUT
    % pkg = package identifier, string
    % (see constructor argument list)
    %
    % OUTPUT
    % obj = object instance, Measure scalar
    %
    % NOTES
    % Do not shadow this function
    % The package directory must in the environment path
    % (MATLAB) Omit the '+' prefix when identifying package names
    function obj=factory(pkg,uri)
      obj=feval([pkg,'.',pkg],uri);
      assert(isa(obj,'Measure'));
    end
  end
  
  methods (Access=protected)
    % Protected method to construct a Measure
    %
    % INPUT
    % uri = uniform resource identifier, string
    %
    % NOTES
    % The URI should identify a hardware resource or DataContainer
    % URI examples:
    %   'file://dev/camera0'
    %   'matlab:middleburyData'
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@Measure(uri);
    % Non-subclasses should instantiate this class using its factory method
    function this=Measure(uri)
      assert(isa(uri,'char'));
    end
  end
  
  methods (Abstract=true)   
    % Find a limited set of edges in the adjacency matrix of the cost graph
    %
    % INPUT
    % kaMin = lower bound of lower node index, uint32 scalar
    % kbMin = lower bound of upper node index, uint32 scalar
    %
    % OUTPUT
    % ka = lower node index for each edge, uint32 N-by-1
    % kb = upper node index for each edge, uint32 N-by-1
    %
    % NOTES
    % The number of edges returned is bounded:
    %   numel(ka) <= (last(this)-kaMin+1)*(last(this)-kbMin+1)
    % If there are no edges, then the outputs are empty
    % Output indices are sorted in ascending order,
    %   first by lower index ka, then by upper index kb
    % If the graph is diagonal, then ka and kb are identical vectors
    % Throws an exception if any input is of the wrong size
    [ka,kb]=findEdges(this,kaMin,kbMin);
    
    % Evaluate the cost of a single edge given a trajectory
    %
    % INPUT
    % x = trajectory to evaluate, Trajectory scalar
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
    % For a normal distribution
    %   Cost is the negative natural log likelihood of the distribution
    %   Typical costs are in the range [0,4.5]
    % Throws an exception if any input is of the wrong size
    % Throws an exception if node indices do not correspond to an edge
    cost=computeEdgeCost(this,x,ka,kb);
  end
  
end
