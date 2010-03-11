classdef linearKalmanDynamicModel < linearKalmanDynamicModel.linearKalmanDynamicModelConfig & dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    block
    ta
    tb
    priorPosition
    priorRotation
    priorPositionRate
    priorRotationRate
    noiseHypothesis
  end
  
  methods (Static=true,Access=public)
    function description=getInitialBlockDescription
      description=struct('numLogical',uint32(0),'numUint32',uint32(1));
    end
  
    function description=getExtensionBlockDescription
      description=struct('numLogical',uint32(0),'numUint32',uint32(0));
    end
    
    function blocksPerSecond=getUpdateRate
      blocksPerSecond=0;
      % blocksPerSecond=linearKalmanDynamicModel.linearKalmanDynamicModelConfig.blocksPerSecond;
    end
  end
  
  methods (Access=public)
    function this=linearKalmanDynamicModel(uri,initialTime,initialBlock)
      this=this@dynamicModel(uri,initialTime,initialBlock);
      this.block=struct('logical',{},'uint32',{});
      this.ta=initialTime;
      this.tb=initialTime;
      this.noiseHypothesis=initialBlock2noise(initialBlock);
      
      try
        [scheme,resource]=strtok(uri,':');
        switch(scheme)
          case 'matlab'
            container=eval(resource(2:end));
            if(hasReferenceTrajectory(container))
              xRef=getReferenceTrajectory(container);
              this.priorPosition=evaluate(xRef,domain(xRef)); % get initial position
              this.priorRotation=[1;0;0;0];
              this.priorPositionRate=[0;0;0];
              this.priorRotationRate=[0;0;0;0];
%               this.t=this.ta:(1/this.blocksPerSecond):1000;
%               x=evaluate(xRef,this.t);
%               noise=cumsum(this.sigma*randn(1,numel(this.t)));
%               this.xNoisy=x(1,:)+noise;
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

    function replaceInitialBlock(this,initialBlock)
      this.noiseHypothesis=initialBlock2noise(initialBlock);
    end

    function cost=computeInitialBlockCost(this,initialBlock)
      noise=initialBlock2noise(initialBlock);
      dnorm=(this.priorPosition(1)-noise(1))./this.priorSigma(1);
      cost=0.5*dnorm.*dnorm;
    end
    
    function numBlocks=getNumExtensionBlocks(this)
      numBlocks=numel(this.block);
    end
    
    function replaceExtensionBlocks(this,k,block)
      if(isempty(k))
        return;
      end
      k=k+1; % convert to one-based index
      assert(k(end)<=numel(this.block));
      this.block(k)=block;
    end
    
    function appendExtensionBlocks(this,blocks)
      assert(numel(blocks)==1);
      this.block=blocks;
      this.tb=inf;
    end
    
    function cost=computeExtensionBlockCost(this,block)
      assert(isa(this,'dynamicModle'));
      assert(isa(block,'struct'));
      cost=0;
    end
     
    function [ta,tb]=domain(this)
      ta=this.ta;
      tb=this.tb;
    end
   
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      N=numel(t);
      position=repmat(this.priorPosition-this.noiseHypothesis,[1,N]);
      rotation=repmat(this.priorRotation,[1,N]);
      positionRate=repmat(this.priorPositionRate,[1,N]);
      rotationRate=repmat(this.priorRotationRate,[1,N]);
% ASSUMPTION: discrete time
% ASSUMPTION: derivatives are not used
%       N=numel(t);
%       dt=t-this.ta;
%       dk=dt*this.blocksPerSecond;
%       dkFloor=floor(dk);
%       dkCeil=ceil(dk);
%       dkPlus=dkFloor+1;
%       noise=block2noise(this.block,dkCeil(end));
%       position=this.xNoisy(dkPlus)-noise(dkPlus);
    end
  end
  
end

function noise=initialBlock2noise(initialBlock)
  sixthIntMax=715827883;
  noise=[double(initialBlock.uint32)/sixthIntMax-3;0;0];
end

%   if(k==0)
%     noise=0;
%   else
%     halfIntMax=2147483647.5;
%     noise=cumsum([0,double(blocks(1:k).uint32)]/halfIntMax-1);
%   end
