% This class augments a trajectory with defining parameters
%
% NOTES
% This class depends on parameter blocks of the following form
%   description.numLogical = number of 1-bit logical parameters, uint32 scalar
%   description.numUint32 = number of 32-bit unsigned integer parameters, uint32 scalar
%   block.logical = logical parameters, logical 1-by-numLogical
%   block.uint32 = unsigned integer parameters, uint32 1-by-numUint32
% There are seperate block descriptions for initial and extension blocks
% The range of uint32 is [0,4294967295]
% Parameters may be treated as range-bounded doubles via static casting
classdef dynamicModel < trajectory
  
  properties (Constant=true,GetAccess=public)
    baseClass='dynamicModel';
  end
  
  methods (Access=protected)
    % Construct a dynamic model
    %
    % INPUT
    % uri = uniform resource identifier, string
    % initialTime = initial lower bound of the trajectory domain, double scalar
    % initialBlock = (see above), struct scalar
    %
    % NOTES
    % The URI should identify a hardware resource or dataContainer
    % URI examples:
    %   'file://dev/camera0'
    %   'matlab:middleburyData.middleburyData'
    % Each subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@dynamicModel(uri,initialTime,initialBlock);
    function this=dynamicModel(uri,initialTime,initialBlock)
      assert(isa(uri,'char'));
      assert(isa(initialTime,'double'));
      assert(isa(initialBlock,'struct'));
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
    % blocksPerSecond = each block will extend the domain the reciprical of this rate, double scalar
    blocksPerSecond=getUpdateRate;
  end
  
  methods (Abstract=true,Access=public)
    % Replace the initial block
    %
    % INPUT
    % initialBlock = (see above), struct scalar
    %
    % NOTES
    % This function modifies the object instance
    replaceInitialBlock(this,initialBlock);
    
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
    cost=computeInitialBlockCost(this,initialBlock);
    
    % Get the total number of extension blocks
    %
    % OUTPUT
    % num = total number of extension blocks, uint32 scalar
    num=getNumExtensionBlocks(this);
    
    % Replace multiple extension blocks
    %
    % INPUT
    % k = zero-based indices of block locations sorted in ascending order, uint32 N-by-1
    % blocks = (see above), struct N-by-1
    %
    % NOTES
    % Unsigned integers may be treated as range-bounded doubles via static casting
    % This function modifies the object instance
    % Throws an exception if any index is is invalid
    replaceExtensionBlocks(this,k,blocks);

    % Extend the time domain by appending consecutive extension blocks
    %
    % INPUT
    % blocks = (see above), struct M-by-1
    %
    % NOTES
    % This function modifies the object instance
    appendExtensionBlocks(this,blocks);
    
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
    cost=computeExtensionBlockCost(this,block);
  end
    
end
