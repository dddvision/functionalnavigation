% This class augments a Trajectory with defining parameters
%
% NOTES
% This class depends on parameter blocks of the following form
%   description.numLogical = number of 1-bit logical parameters, uint32 scalar
%   description.numUint32 = number of 32-bit unsigned integer parameters, uint32 scalar
%   block.logical = logical parameters, logical 1-by-numLogical
%   block.uint32 = unsigned integer parameters, uint32 1-by-numUint32
% There are seperate block descriptions for initial and extension blocks
% Each uint32 parameter may be treated as range-bounded double via static casting
% The range of uint32 is [0,4294967295]
classdef DynamicModel < Trajectory
  
  properties (Constant=true,GetAccess=public)
    frameworkClass='DynamicModel';
  end
  
  methods (Static=true,Access=public)
    % Instantiate a subclass by name
    %
    % INPUT
    % pkg = package identifier, string
    % (see constructor argument list)
    %
    % OUTPUT
    % obj = object instance, DynamicModel scalar
    %
    % NOTES
    % The package directory must in the environment path
    % (MATLAB) Omit the '+' prefix when identifying package names
    function obj=factory(pkg,initialTime,initialBlock,uri)
      obj=feval([pkg,'.',pkg],initialTime,initialBlock,uri);
      assert(isa(obj,'DynamicModel'));
    end
  end
  
  methods (Access=protected)
    % Construct a dynamic model
    %
    % INPUT
    % initialTime = initial lower bound of the trajectory domain, double scalar
    % initialBlock = (see above), struct scalar
    % uri = (see Measure class constructor)
    %
    % NOTES
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@DynamicModel(initialTime,initialBlock,uri);
    % Throws an exception if any input is of the wrong size
    function this=DynamicModel(initialTime,initialBlock,uri)
      assert(isa(initialTime,'double'));
      assert(isa(initialBlock,'struct'));
      assert(isa(uri,'char'));
      assert(numel(initialTime)==1);
      assert(numel(initialBlock)==1);
    end    
  end
  
  methods (Abstract=true,Static=true,Access=public)
    % Get description of the initial block
    %
    % OUTPUT
    % description = (see above), struct scalar
    description=getInitialBlockDescription;
    
    % Get description of a extension block
    %
    % OUTPUT
    % description = (see above), struct scalar
    description=getExtensionBlockDescription;
    
    % Get the conversion between number of extension blocks and associated time domain extension
    %
    % OUTPUT
    % updateRate = each block will extend the domain the reciprical of this rate, double scalar
    %
    % NOTES
    % The units for update rate are blocks per second
    % If the dynamic model takes no extension blocks then the update rate is 0
    updateRate=getUpdateRate;
  end
  
  methods (Abstract=true,Access=public)
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
    %   Cost is the negative log likelihood of the distribution
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
    %   Cost is the negative log likelihood of the distribution
    %   Typical costs are in the range [0,4.5]
    % Throws an exception if given block is not a struct scalar
    cost=computeExtensionBlockCost(this,block);
    
    % Get the total number of extension blocks
    %
    % OUTPUT
    % numExtensionBlocks = total number of extension blocks, uint32 scalar
    numExtensionBlocks=getNumExtensionBlocks(this);
    
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
