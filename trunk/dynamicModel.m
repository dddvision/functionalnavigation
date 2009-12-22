% This class augments a trajectory with defining parameters
classdef dynamicModel < trajectory
  
  properties (Constant=true,GetAccess=public)
    baseClass='dynamicModel';
  end
  
  methods (Access=protected)
    % Construct a dynamic model
    %
    % INPUT
    % initialTime = initial lower bound of the trajectory domain, double scalar
    % blocksPerSecond = conversion between number of blocks and the time 
    %                   span of the trajectory domain, double scalar
    %
    % NOTES
    % The default body state at the initial time is at the origin:
    %   position = [0;0;0];
    %   rotation = [1;0;0;0];
    %   positionRate = [0;0;0];
    %   rotationRate = [0;0;0;0];
    % A subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@dynamicModel(initialTime,blocksPerSecond);
    function this=dynamicModel(initialTime,blocksPerSecond)
      assert(isa(initialTime,'double'));
      assert(isa(blocksPerSecond,'double'));
    end
  end
  
  methods (Abstract=true,Static=true,Access=public)
    % Get a description of a single block of parameters
    %
    % OUTPUT
    % description.numLogical = number of 1-bit logical parameters, uint32 scalar
    % description.numUint32 = number of 32-bit unsigned integer parameters, uint32 scalar
    description=getBlockDescription;
  end
  
  methods (Abstract=true,Access=public)
    % Get the total number of blocks
    %
    % OUTPUT
    % numBlocks = total number of blocks, uint32 scalar
    numBlocks=getNumBlocks(this);
    
    % Set the body state at the initial time
    %
    % INPUT
    % See output of trajectory.evaluate()
    %
    % NOTES
    % This function modifies the object instance
    setInitialState(this,position,rotation,positionRate,rotationRate);
    
    % Replace multiple blocks of parameters
    %
    % INPUT
    % k = zero-based indices of block locations sorted in ascending order, uint32 N-by-1
    % blocks = struct N-by-1
    % blocks(k).logical = logical parameters, logical numLogical-by-1
    % blocks(k).uint32 = unsigned integer parameters, uint32 numUint32-by-1
    %
    % NOTES
    % Unsigned integers may be treated as range-bounded doubles via static casting
    % This function modifies the object instance
    % Throws an exception if any index is is invalid
    replaceBlocks(this,k,blocks);

    % Extend the time domain by appending consecutive blocks of parameters
    %
    % INPUT
    % blocks = struct M-by-1
    % blocks(k).logical = logical parameters, logical numLogical-by-1
    % blocks(k).uint32 = unsigned integer parameters, uint32 numUint32-by-1
    %
    % NOTES
    % Unsigned integers may be treated as range-bounded doubles via static casting
    % This function modifies the object instance
    appendBlocks(this,blocks);
  end
    
end
