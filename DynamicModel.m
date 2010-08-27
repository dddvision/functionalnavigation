% This class augments a Trajectory with defining parameters
%
% NOTES
% Several member functions interact with groups of parameters called blocks
% There are seperate block descriptions for initial and extension blocks
% Each block has zero or more logical parameters and zero or more uint32 parameters
% Each uint32 parameter may be treated as range-bounded double via static casting
% The range of uint32 is [0,4294967295]
classdef DynamicModel < Trajectory
    
  methods (Access=protected,Static=true)
    % Protected method to construct a component
    %
    % INPUT
    % initialTime = finite lower bound of the trajectory time domain, double scalar
    % uri = (see Measure class constructor)
    %
    % NOTES
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@DynamicModel(initialTime,uri);
    function this=DynamicModel(initialTime,uri)
      assert(isa(initialTime,'double'));
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
      if(DynamicModel.isConnected(name))
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
    % obj = object instance, DynamicModel scalar
    %
    % NOTES
    % Do not shadow this function
    % Throws an error if the component is not connected
    function obj=factory(name,initialTime,uri)
      if(DynamicModel.isConnected(name))
        cF=pFactoryList(name);
        obj=cF.(name)(initialTime,uri);
        assert(isa(obj,'DynamicModel'));
      else
        error('DynamicModel is not connected to the requested component');
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
    % Get number of parameters in each initial block
    %
    % OUTPUT
    % num = number of parameters in each block, const uint32 scalar
    num=numInitialLogical(this);
    num=numInitialUint32(this);
    num=numExtensionLogical(this);
    num=numExtensionUint32(this);

    % Get the number of extension blocks
    %
    % OUTPUT
    % num = number of extension blocks, uint32 scalar
    num=numExtensionBlocks(this);
    
    % Get/Set parameters
    %
    % INPUT
    % blockIndex = zero-based block index, uint32 scalar
    % parameterIndex = zero-based parameter index within each block, uint32 scalar
    %
    % INPUT/OUTPUT
    % value = parameter value, logical or uint32 scalar
    %
    % NOTES
    % Throws an exception if any index is outside of the range specified by other member functions
    value=getInitialLogical(this,parameterIndex);
    value=getInitialUint32(this,parameterIndex);
    value=getExtensionLogical(this,blockIndex,parameterIndex);
    value=getExtensionUint32(this,blockIndex,parameterIndex);
    setInitialLogical(this,parameterIndex,value);
    setInitialUint32(this,parameterIndex,value);
    setExtensionLogical(this,blockIndex,parameterIndex,value);
    setExtensionUint32(this,blockIndex,parameterIndex,value);

    % Compute the cost associated with a block
    %
    % INPUT
    % blockIndex = zero-based block index, uint32 scalar
    %
    % OUTPUT
    % cost = non-negative cost associated with each block, double scalar
    %
    % NOTE
    % A block with zero parameters returns zero cost
    % Cost is the negative natural log of the probability mass function P normalized by its peak value Pinf
    % Typical costs are less than 20 because it is difficult to model events when P/Pinf < 1E-9
    cost=computeInitialBlockCost(this);
    cost=computeExtensionBlockCost(this,blockIndex);
    
    % Extend the time domain by appending one extension block
    %
    % NOTES
    % Has no effect if the upper bound of the domain is infinite
    extend(this);
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
