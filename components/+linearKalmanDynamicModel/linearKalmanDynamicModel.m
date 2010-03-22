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
      z=initialBlock2deviation(initialBlock);
      cost=0.5*dot(z,z);
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
      position(1,:)=position(1,:)+this.positionOffset;
%       position(1,:)=position(1,:)+this.positionOffset+this.positionRateOffset*(t-this.initialTime);
%       if(nargout>2)
%         positionRate(1,:)=positionRate(1,:)+repmat(this.positionRateOffset,[1,numel(t)]);
%       end
        
      % compute correction based on given initial parameters
      z=initialBlock2deviation(this.initialBlock);
      position(1,:)=position(1,:)-this.positionDeviation*z(1);
%       position(1,:)=position(1,:)-this.positionDeviation*z(1)-this.positionRateDeviation*z(2)*(t-this.initialTime);
%       if(nargout>2)
%         positionRate(1,:)=positionRate(1,:)-repmat(this.positionRateDeviation*z(2),[1,numel(t)]);
%       end
    end
  end
end
  
function z=initialBlock2deviation(initialBlock)
  sixthIntMax=715827883;
  z=double(initialBlock.uint32)/sixthIntMax-3;
end
