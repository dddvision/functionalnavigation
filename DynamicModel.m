% This class augments a Trajectory with defining parameters
%
% NOTES
% Several member functions interact with groups of parameters called blocks
% There are seperate block descriptions for initial and extension blocks
% Each block has zero or more logical parameters and zero or more uint32 parameters
% Each uint32 parameter may be treated as range-bounded double via static casting
% The range of uint32 is [0,4294967295]
classdef DynamicModel < Trajectory
  
  methods (Static=true,Access=public)
    % Framework class identifier
    %
    % OUTPUT
    % text = name of the framework class, string
    function text=frameworkClass
      text='DynamicModel';
    end
    
    % Public method to construct a DynamicModel
    %
    % INPUT
    % pkg = package identifier, string
    % (see constructor argument list)
    %
    % OUTPUT
    % obj = object instance, DynamicModel scalar
    %
    % NOTES
    % Do not shadow this function
    % The package directory must in the environment path
    % (MATLAB) Omit the '+' prefix when identifying package names
    function obj=factory(pkg,initialTime,uri)
      obj=feval([pkg,'.',pkg],initialTime,uri);
      assert(isa(obj,'DynamicModel'));
    end
  end
  
  methods (Access=protected)
    % Protected method to construct a DynamicModel
    %
    % INPUT
    % initialTime = initial lower bound of the trajectory domain, double scalar
    % uri = (see Measure class constructor)
    %
    % NOTES
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@DynamicModel(initialTime,uri);
    % Throws an exception if any input is of the wrong size
    function this=DynamicModel(initialTime,uri)
      assert(isa(initialTime,'double'));
      assert(numel(initialTime)==1);
      assert(isa(uri,'char'));
    end
  end
  
  methods (Abstract=true,Access=public)
    % Get the conversion between number of extension blocks and associated time domain extension
    %
    % OUTPUT
    % rate = each block will extend the domain the reciprical of this rate, const double scalar
    %
    % NOTES
    % The units for update rate are blocks per second
    % If the dynamic model takes no extension blocks then the update rate is 0
    rate=updateRate(this);
       
    % Get number of parameters in each block
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
    % For a normal distribution
    %   Cost is the negative natural log likelihood of the distribution
    %   Typical costs are in the range [0,4.5]
    cost=computeInitialBlockCost(this);
    cost=computeExtensionBlockCost(this,blockIndex);
    
    % Extend the time domain by appending extension blocks
    %
    % INPUT
    % num = number of blocks to append, uint32 scalar
    %
    % NOTES
    % Throws an exception if the update rate is 0
    extend(this,num);
  end
    
end
