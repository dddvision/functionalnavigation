% This class defines a graph of measures between sensor data and a trajectory
%
% NOTES
% A measure may depend on data from multiple sensors
% Each measure is assumed to be independent
% Measures do not disclose their sources of information
% Each graph edge is assumed to be independent, and this means that correlated
%   sensor noise must be modeled and mitigated behind the measure interface
classdef Measure < Sensor

  methods (Access=protected,Static=true)
    % Protected method to construct a component
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
    
    % Establish connection between framework class and component
    %
    % INPUT
    % name = component identifier, string
    % cD = function that returns a user friendly description, function handle
    % cF = function that can instantiate the subclass, function handle
    %
    % NOTES
    % The description may be truncated after a few hundred characters when displayed
    % The description should not contain line feed or return characters
    % A component can connect to multiple framework classes
    % (C++) Call this function prior to the invocation of main() using an initializer class
    % (MATLAB) Call this function from initialize()
    function connect(name,cD,cF)
      if(isa(cD,'function_handle')&&...
         isa(cF,'function_handle'))
         pDescriptionList(name,cD);
         pFactoryList(name,cF);
      end
    end
  end
      
  methods (Access=public,Static=true)
    % Check if a named subclass is connected with this base class
    %
    % INPUT
    % name = component identifier, string
    %
    % OUTPUT
    % flag = true if the subclass exists and is connected to this base class, logical scalar
    %
    % NOTES
    % Do not shadow this function
    % A package directory identifying the component must in the environment path
    % Omit the '+' prefix when identifying package names
    function flag=isConnected(name)
      flag=false;
      if(exist([name,'.',name],'class'))
        try
          feval([name,'.',name,'.initialize'],name);
        catch err
          err.message;
        end  
        if(isfield(pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    % Get user friendly description of a component
    %
    % INPUT
    % name = component identifier, string
    %
    % OUTPUT
    % text = user friendly description, string
    %
    % NOTES
    % Do not shadow this function
    % If the component is not connected then the output is an empty string
    function text=description(name)
      text='';
      if(Measure.isConnected(name))
        dL=pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    % Public method to construct a component
    %
    % INPUT
    % name = component identifier, string
    % (see constructor argument list)
    %
    % OUTPUT
    % obj = object instance, Measure scalar
    %
    % NOTES
    % Do not shadow this function
    % Throws an error if the component is not connected
    function obj=factory(name,uri)
      if(Measure.isConnected(name))
        cF=pFactoryList(name);
        obj=cF.(name)(uri);
        assert(isa(obj,'Measure'));
      else
        error('Measure is not connected to the requested component');
      end
    end
  end
  
  methods (Abstract=true,Access=protected,Static=true)
    % (MATLAB) Initializes connections between a component and one or more framework classes
    %
    % INPUT
    % name = component identifier, string
    initialize(name);
  end
  
  methods (Abstract=true,Access=public,Static=false)
    % Find a limited set of graph edges in the adjacency matrix of the cost graph
    %
    % INPUT
    % x = predicted trajectory that can be used to compute the graph structure, Trajectory scalar
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

% Storage for component descriptions
function dL=pDescriptionList(name,cD)
  persistent descriptionList
  if(nargin==2)
    descriptionList.(name)=cD;
  else
    dL=descriptionList;
  end
end

% Storage for component factories
function fL=pFactoryList(name,cF)
  persistent factoryList
  if(nargin==2)
    factoryList.(name)=cF;
  else
    fL=factoryList;
  end
end
