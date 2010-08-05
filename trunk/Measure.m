% This class defines a graph of measures between sensor data and a trajectory
%
% NOTES
% A measure may depend on data from multiple sensors
% Measures do not disclose their sources of information
% Each graph edge is assumed to be independent, and this means that correlated
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
      subclass=[pkg,'.',pkg];
      if(exist(subclass,'class'))
        obj=feval(subclass,uri);
      else
        obj=MeasureBridge(pkg,uri);
      end
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
    % Find a limited set of graph edges in the adjacency matrix of the cost graph
    %
    % INPUT
    % x = trajectory that can be used to compute the graph structure, Trajectory scalar
    % naSpan = maximum difference between lower node index and last node index, uint32 scalar
    % nbSpan = maximum difference between upper node index and last node index, uint32 scalar
    %
    % OUTPUT
    % edgeList = list of edges, GraphEdge N-by-1
    %
    % NOTES
    % Only finds graph edges that are within the domain of the input trajectory,
    %   which is guaranteed to have a fixed lower bound
    % Graph edges may be added on successive calls to refresh, but they are never removed
    % The number of returned graph edges is bounded as follows:
    %   numel(edgeList) <= (naSpan+1)*(nbSpan+1)
    % All information from this measure regarding a unique pair of nodes must be grouped such that
    %   there are no duplicate graph edges in the output 
    % Edges are sorted in ascending order of node indices,
    %   first by lower index, then by upper index
    % If there are no graph edges, then the output is an empty vector
    edgeList=findEdges(this,x,naSpan,nbSpan);
    
    % Evaluate the cost of a single graph edge given a trajectory
    %
    % INPUT
    % x = trajectory to evaluate, Trajectory scalar
    % graphEdge = index of a graph edge in the cost graph returned by findEdges, GraphEdge scalar
    %
    % OUTPUT
    % cost = non-negative cost associated with the graph edge, double scalar
    %
    % NOTES
    % The input trajectory represents the motion of the body frame relative 
    %   to a world frame. If the sensor frame is not coincident with the 
    %   body frame, then the sensor frame offset may need to be 
    %   kinematically composed with the body frame to locate the sensor
    % Cost is the negative natural log of the probability mass function P normalized by its peak value Pinf
    % Typical costs are less than 20 because it is difficult to model events when P/Pinf < 1E-9
    % Throws an exception if node indices do not correspond to an edge
    cost=computeEdgeCost(this,x,graphEdge);
  end
  
end
