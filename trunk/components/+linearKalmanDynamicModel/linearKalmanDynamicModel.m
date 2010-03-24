classdef linearKalmanDynamicModel < linearKalmanDynamicModel.linearKalmanDynamicModelConfig & dynamicModel
  
  properties (Constant=true,GetAccess=private)
    sixthIntMax=715827883;
    extensionBlockCost=0;
    numExtension=uint32(0);
    extensionErrorText='This dynamic model has no extension blocks.';
  end
  
  properties (GetAccess=private,SetAccess=private)
    initialTime
    initialBlock
    xRef
  end
  
  methods (Static=true,Access=public)
    function description=getInitialBlockDescription
      description=struct('numLogical',uint32(0),'numUint32',uint32(2));
    end
  
    function description=getExtensionBlockDescription
      description=struct('numLogical',uint32(0),'numUint32',uint32(0));
    end
    
    function updateRate=getUpdateRate
      updateRate=0;
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
      assert(isa(initialBlock,'struct'));
      z=initialBlock2deviation(this,initialBlock);
      cost=0.5*dot(z,z);
    end
    
    function setInitialBlock(this,initialBlock)
      assert(isa(initialBlock,'struct'));
      assert(numel(initialBlock)==1);
      this.initialBlock=initialBlock;
    end
    
    function initialBlock=getInitialBlock(this)
      initialBlock=this.initialBlock;
    end
      
    function cost=computeExtensionBlockCost(this,block)
      assert(isa(block,'struct'));
      assert(numel(block)==1);
      cost=this.extensionBlockCost;
    end
    
    function numExtensionBlocks=getNumExtensionBlocks(this)
      numExtensionBlocks=this.numExtension;
    end
    
    function setExtensionBlocks(this,k,blocks)
      assert(isa(k,'uint32'));
      assert(isa(blocks,'struct'));
      assert(numel(k)==numel(blocks));
      if(~isempty(k))
        error(this.extensionErrorText);
      end
    end
    
    function blocks=getExtensionBlocks(this,k)
      assert(isa(k,'uint32'));
      if(isempty(k))
        blocks=struct('logical',{},'uint32',{});
      else
        error(this.extensionErrorText);
      end
    end
    
    function appendExtensionBlocks(this,blocks)
      assert(isa(blocks,'struct'));
      if(~isempty(blocks))
        error(this.extensionErrorText);
      end
    end
     
    function [ta,tb]=domain(this)
      ta=this.initialTime;
      tb=Inf;
    end
   
    function [position,rotation,positionRate,rotationRate]=evaluate(this,t)
      [a,b]=domain(this.xRef);
      t(t>b)=b;

      % simulate trajectory with position and velocity offsets
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
      position(1,:)=position(1,:)+this.positionOffset+this.positionRateOffset*(t-this.initialTime);
      if(nargout>2)
        positionRate(1,:)=positionRate(1,:)+repmat(this.positionRateOffset,[1,numel(t)]);
      end
        
      % compute correction based on given initial parameters
      z=initialBlock2deviation(this,this.initialBlock);
      position(1,:)=position(1,:)-this.positionDeviation*z(1)-this.positionRateDeviation*z(2)*(t-this.initialTime);
      if(nargout>2)
        positionRate(1,:)=positionRate(1,:)-repmat(this.positionRateDeviation*z(2),[1,numel(t)]);
      end
    end
  end
  
  methods (Access=private)
    function z=initialBlock2deviation(this,initialBlock)
      z=double(initialBlock.uint32)/this.sixthIntMax-3;
    end
  end
end
