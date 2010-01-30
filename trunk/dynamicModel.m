% This class augments a trajectory with defining parameters
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
    %
    % NOTES
    % The URI should identify a hardware resource or dataContainer
    % URI examples:
    %   'file://dev/camera0'
    %   'matlab:middleburyData.middleburyData'    
    % The default body state at the initial time is at the origin:
    %   position = [0;0;0];
    %   rotation = [1;0;0;0];
    %   positionRate = [0;0;0];
    %   rotationRate = [0;0;0;0];
    % A subclass constructor must pass identical arguments to this 
    %   constructor using the syntax this=this@dynamicModel(uri,initialTime);
    function this=dynamicModel(uri,initialTime)
      assert(isa(uri,'char'));
      assert(isa(initialTime,'double'));
    end    
  end
  
  methods (Abstract=true,Static=true,Access=public)
    % Get a description of a single block of parameters
    %
    % OUTPUT
    % description.numLogical = number of 1-bit logical parameters, uint32 scalar
    % description.numUint32 = number of 32-bit unsigned integer parameters, uint32 scalar
    %
    % NOTES
    % Unsigned integers may be treated as range-bounded doubles via static casting
    description=getBlockDescription;
    
    % Get the conversion between number of blocks and associated time domain extension
    %
    % OUTPUT
    % blocksPerSecond = each block will extend the domain the reciprical of this rate, double scalar
    blocksPerSecond=getUpdateRate;
  end
  
  methods (Abstract=true,Access=public)
    % Get the total number of parameter blocks
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
