classdef LinearKalmanDynamicModel < LinearKalmanDynamicModel.LinearKalmanDynamicModelConfig & DynamicModel
  
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
    function description=initialBlockDescription
      description=struct('numLogical',uint32(0),'numUint32',uint32(2));
    end
  
    function description=extensionBlockDescription
      description=struct('numLogical',uint32(0),'numUint32',uint32(0));
    end
    
    function rate=updateRate
      rate=0;
    end
  end
  
  methods (Access=public)
    function this=LinearKalmanDynamicModel(initialTime,initialBlock,uri)
      this=this@DynamicModel(initialTime,initialBlock,uri);
      this.initialTime=initialTime;
      this.initialBlock=initialBlock;

      try
        [scheme,resource]=strtok(uri,':');
        resource=resource(2:end);
        switch(scheme)
          case 'matlab'
            container=DataContainer.factory(resource);
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
    
    function num=numExtensionBlocks(this)
      num=this.numExtension;
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
   
    function [pose,poseRate]=evaluate(this,t)
      [a,b]=domain(this.xRef);
      t(t>b)=b;

      % simulate trajectory with position and velocity offsets
      if(nargout==1)
        pose=evaluate(this.xRef,t);
      else
        [pose,poseRate]=evaluate(this.xRef,t);
      end
      pose.p(1,:)=pose.p(1,:)+this.positionOffset+this.positionRateOffset*(t-this.initialTime);
      if(nargout>1)
        poseRate.r(1,:)=poseRate.r(1,:)+repmat(this.positionRateOffset,[1,numel(t)]);
      end
        
      % compute correction based on given initial parameters
      z=initialBlock2deviation(this,this.initialBlock);
      pose.p(1,:)=pose.p(1,:)-this.positionDeviation*z(1)-this.positionRateDeviation*z(2)*(t-this.initialTime);
      if(nargout>1)
        poseRate.r(1,:)=poseRate.r(1,:)-repmat(this.positionRateDeviation*z(2),[1,numel(t)]);
      end
    end
  end
  
  methods (Access=private)
    function z=initialBlock2deviation(this,initialBlock)
      z=double(initialBlock.uint32)/this.sixthIntMax-3;
    end
  end
end
