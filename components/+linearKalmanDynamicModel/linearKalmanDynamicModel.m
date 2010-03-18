classdef linearKalmanDynamicModel < linearKalmanDynamicModel.linearKalmanDynamicModelConfig & dynamicModel
  
  properties (GetAccess=private,SetAccess=private)
    initialTime
    initialBlock
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
      fprintf('\n\n%s',class(this));
      this.initialTime=initialTime;
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

    function cost=computeInitialBlockCost(this,initialBlock)
      assert(isa(this,'dynamicModel'));
      assert(isa(initialBlock,'struct'));
      noise=initialBlock2noise(initialBlock);
      cost=0.5*dot(noise,noise);
    end
    
    function setInitialBlock(this,initialBlock)
      assert(isa(initialBlock,'struct'));
      assert(numel(initialBlock)==1);
      this.initialBlock=initialBlock;
    end

    function cost=computeExtensionBlockCost(this,block)
      assert(isa(this,'dynamicModel'));
      assert(isa(block,'struct'));
      assert(numel(block)==1);
      cost=0;
    end
    
    function numExtensionBlocks=getNumExtensionBlocks(this)
      assert(isa(this,'dynamicModel'));
      numExtensionBlocks=uint32(0);
    end
    
    function setExtensionBlocks(this,k,block)
      assert(isa(this,'dynamicModel'));
      assert(isa(k,'uint32'));
      assert(isa(block,'struct'));
      assert(numel(k)==numel(blocks));
      if(isempty(blocks))
        return;
      end
      error('This dynamic model accepts no extension blocks.');
    end
    
    function appendExtensionBlocks(this,blocks)
      assert(isa(this,'dynamicModel'));
      assert(isa(blocks,'struct'));
      if(isempty(blocks))
        return;
      end
      error('The time domain of this dynamic model cannot be extended.');
    end
     
    function [ta,tb]=domain(this)
      ta=this.initialTime;
      tb=Inf;
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
