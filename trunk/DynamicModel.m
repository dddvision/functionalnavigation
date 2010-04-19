% This class augments a Trajectory with defining parameters
%
% NOTES
% This class depends on parameter blocks of the following form
%   block.logical = logical parameters, logical 1-by-numLogical
%   block.uint32 = unsigned integer parameters, uint32 1-by-numUint32
% There are seperate block descriptions for initial and extension blocks
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
    % Get number of logical parameters in the initial block
    %
    % OUTPUT
    % num = number of logical parameters, uint32 scalar
    num=numInitialLogical(this);
    
    % Get number of uint32 parameters in the initial block
    %
    % OUTPUT
    % num = number of integer parameters, uint32 scalar
    num=numInitialUint32(this);
    
    % Get number of logical parameters in each extension block
    %
    % OUTPUT
    % num = number of logical parameters, uint32 scalar
    num=numExtensionLogical(this);
    
    % Get number of uint32 parameters in each extension block
    %
    % OUTPUT
    % num = number of integer parameters, uint32 scalar
    num=numExtensionUint32(this);
    
    % Get the conversion between number of extension blocks and associated time domain extension
    %
    % OUTPUT
    % rate = each block will extend the domain the reciprical of this rate, double scalar
    %
    % NOTES
    % The units for update rate are blocks per second
    % If the dynamic model takes no extension blocks then the update rate is 0
    rate=updateRate(this);

    % Compute the cost associated with the initial block
    %
    % INPUT
    % initialBlock = (see above), struct scalar
    %
    % OUTPUT
    % cost = non-negative cost associated with the block, double scalar
    %
    % NOTE
    % For a normal distribution
    %   Cost is the negative natural log likelihood of the distribution
    %   Typical costs are in the range [0,4.5]
    % Throws an exception if given block is not a struct scalar
    cost=computeInitialBlockCost(this,initialBlock);
    
    % Set/Get the the initial block
    %
    % INPUT/OUTPUT
    % initialBlock = (see above), struct scalar
    %
    % NOTES
    % The set function throws an exception if the given block is not a struct scalar
    setInitialBlock(this,initialBlock);
    initialBlock=getInitialBlock(this);
    
    % Compute the cost associated with an extension block
    %
    % INPUT
    % block = (see above), struct scalar
    %
    % OUTPUT
    % cost = non-negative cost associated with the block, double scalar
    %
    % NOTE
    % For a normal distribution
    %   Cost is the negative natural log likelihood of the distribution
    %   Typical costs are in the range [0,4.5]
    % Throws an exception if given block is not a struct scalar
    cost=computeExtensionBlockCost(this,block);
    
    % Get the total number of extension blocks
    %
    % OUTPUT
    % num = total number of extension blocks, uint32 scalar
    num=numExtensionBlocks(this);
    
    % Set/Get multiple extension blocks
    %
    % INPUT
    % k = zero-based indices of block locations sorted in ascending order, uint32 N-by-1
    %
    % INPUT/OUTPUT
    % blocks = (see above), struct N-by-1
    %
    % NOTES
    % Vector arguments may be empty without consequence (no blocks will be set/returned)
    % Throws an exception if any index is outside of the range [0,numExtensionBlocks-1]
    % Unsorted indices may cause unexpected behaviour
    % The set function throws an exception if the number of indices does not match the number of blocks
    setExtensionBlocks(this,k,blocks);
    blocks=getExtensionBlocks(this,k);

    % Extend the time domain by appending consecutive extension blocks
    %
    % INPUT
    % blocks = (see above), struct M-by-1
    %
    % NOTES
    % Vector of blocks may be empty without consequence (no blocks will be appended)
    % Throws an exception if the update rate is 0
    appendExtensionBlocks(this,blocks);
  end
    
end
