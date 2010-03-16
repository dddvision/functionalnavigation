classdef linearKalmanDynamicModel < linearKalmanDynamicModel.linearKalmanDynamicModelConfig & dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    initialBlock
    block
    ta
    tb
    xRef
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
    end
  end
  
  methods (Access=public)
    function this=linearKalmanDynamicModel(uri,initialTime,initialBlock)
      this=this@dynamicModel(uri,initialTime,initialBlock);
      this.block=struct('logical',{},'uint32',{});
      this.ta=initialTime;
      this.tb=initialTime;
      this.initialBlock=initialBlock;
      
      try
        [scheme,resource]=strtok(uri,':');
        switch(scheme)
          case 'matlab'
            container=eval(resource(2:end));
            if(hasReferenceTrajectory(container))
              this.xRef=getReferenceTrajectory(container);
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
      this.initialBlock=initialBlock;
    end

    function cost=computeInitialBlockCost(this,initialBlock)
      assert(isa(this,'dynamicModel'));
      noise=initialBlock2noise(initialBlock);
      cost=0.5*dot(noise,noise);
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
      assert(isa(this,'dynamicModel'));
      assert(isa(block,'struct'));
      cost=0;
    end
     
    function [ta,tb]=domain(this)
      ta=this.ta;
      tb=this.tb;
    end
   
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      [a,b]=domain(this.xRef);
      t(t>b)=b;
      switch(nargout)
        case 1
          position=evaluate(this.xRef,t);
        case 2
          [position,rotation]=evaluate(this.xRef,t);
        case 3
          [position,rotation,positionRate]=evaluate(this.xRef,t);
        otherwise
          [position,rotation,positionRate,rotationRate]=evaluate(this.xRef,t);
      end
      N=numel(t);
      noise=initialBlock2noise(this.initialBlock);
      position=position+repmat([this.simulatedInitialError;0;0]-sqrt(this.priorVariance)*noise,[1,N]);
    end
  end

end
  
function z=initialBlock2noise(initialBlock)
  sixthIntMax=715827883;
  z=[double(initialBlock.uint32)/sixthIntMax-3;0;0];
end
