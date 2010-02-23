classdef linearKalmanDynamicModel < linearKalmanDynamicModel.linearKalmanDynamicModelConfig & dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    block
    t
    ta
    tb
    initialPosition
    initialRotation
    initialPositionRate
    initialRotationRate
    xNoisy
    sigma
  end
  
  methods (Static=true,Access=public)
    function description=getBlockDescription
      description=struct('numLogical',0,'numUint32',1);
    end
    
    function blocksPerSecond=getUpdateRate
      blocksPerSecond=linearKalmanDynamicModel.linearKalmanDynamicModelConfig.blocksPerSecond;
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
      this.sigma=3; % ASSUMPTION: fixed known noise parameter
      
      this.ta=ta;
      this.tb=ta;
      try
        [scheme,resource]=strtok(uri,':');
        switch(scheme)
          case 'matlab'
            container=eval(resource(2:end));
            if(hasReferenceTrajectory(container))
              xRef=getReferenceTrajectory(container);
              this.t=this.ta:(1/this.blocksPerSecond):1000;
              x=evaluate(xRef,this.t);
              noise=cumsum(this.sigma*randn(1,numel(this.t)));
              this.xNoisy=x(1,:)+noise;
            else
              error('Simulator requires reference trajectory');
            end
          otherwise
            error('Unrecognized resource identifier in URI');
        end
      catch err
        error('Failed to open data resource: %s',err.message);
      end
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
   
    % ASSUMPTION: discrete time
    % ASSUMPTION: derivatives are not used
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      N=numel(t);
      dt=t-this.ta;
      dk=dt*this.blocksPerSecond;
      dkFloor=floor(dk);
      dkCeil=ceil(dk);
      dkPlus=dkFloor+1;
      noise=block2noise(this.block,dkCeil(end));
      position=this.xNoisy(dkPlus)-noise(dkPlus);
      rotation=repmat([1;0;0;0],[1,N]);
      positionRate=zeros(3,N);
      rotationRate=zeros(4,N);
    end
  end
  
end

function noise=block2noise(blocks,k)
  if(k==0)
    noise=0;
  else
    halfIntMax=2147483647.5;
    noise=cumsum([0,double(blocks(1:k).uint32)]/halfIntMax-1);
  end
end
