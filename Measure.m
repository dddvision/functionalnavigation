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
    % Find a limited set of edges in the adjacency matrix of the cost graph
    %
    % INPUT
    % kaSpan = maximum difference between lower node index and last node index, uint32 scalar
    % kbSpan = maximum difference between upper node index and last node index, uint32 scalar
    %
    % OUTPUT
    % edgeList = list of edges, Edge N-by-1
    %
    % NOTES
    % The number of edges returned is bounded:
    %   numel(edges) <= (kaSpan+1)*(kbSpan+1)
    % If there are no edges, then the outputs are empty
    % Edges are sorted in ascending order of node indices,
    %   first by lower index, then by upper index
    % Throws an exception if any input is of the wrong size
    edgeList=findEdges(this,kaSpan,kbSpan);
    
    % Evaluate the cost of a single edge given a trajectory
    %
    % INPUT
    % x = trajectory to evaluate, Trajectory scalar
    % edge = an edge in the cost graph returned by findEdges, Edge scalar
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
    cost=computeEdgeCost(this,x,edge);
  end
  
end
