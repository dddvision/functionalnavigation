classdef linearKalmanDynamicModel < dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    block
    ta
    tb
    initialPosition
    initialRotation
    initialPositionRate
    initialRotationRate
    blocksPerSecond=0.1; % ASSUMPTION: fixed known time step
  end
  
  methods (Static=true,Access=public)
    function description=getBlockDescription
      description=struct('numLogical',0,'numUint32',1);
    end
    
    function blocksPerSecond=getUpdateRate
      blocksPerSecond=this.blocksPerSecond;
    end
    
    function cost=computeBlockCost(block)
      halfIntMax=2147483647.5;
      x=double(block.uint32)/halfIntMax-1;
      cost=3*(x*x);
    end
  end
  
  methods (Access=public)
    function this=linearKalmanDynamicModel(uri,ta)
      this=this@dynamicModel(uri,ta);
      this.block=struct('logical',{},'uint32',{});
      this.initialPosition=[0;0;0]; % ASSUMPTION: known initial conditions
      this.initialRotation=[1;0;0;0];
      this.initialPositionRate=[0;0;0];
      this.initialRotationRate=[0;0;0];
      this.ta=ta;
      this.tb=ta;
    end

    function numBlocks=getNumBlocks(this)
      numBlocks=numel(this.block);
    end
    
    function setInitialState(this,position,rotation,positionRate,rotationRate)
      this.initialPosition=position;
      this.initialRotation=rotation;
      this.initialPositionRate=positionRate;
      this.initialRotationRate=rotationRate;
    end
    
    function replaceBlocks(this,k,block)
      if(isempty(k))
        return;
      end
      k=k+1; % convert to one-based index
      assert(k(end)<=numel(this.block));
      this.block(k)=block;
    end
    
    function appendBlocks(this,blocks)
      this.block=cat(2,this.block,blocks);
      N=numel(this.block);
      this.tb=this.ta+N/this.blocksPerSecond;
    end
     
    function [ta,tb]=domain(this)
      ta=this.ta;
      tb=this.tb;
    end
   
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
%       N=numel(t);
%       
%       
%       
%       position=
%       positionRate=
% 
%       rotation=repmat([1;0;0;0],[1,N]);
%       rotationRate=zeros(4,N);
    end
  end
  
end
