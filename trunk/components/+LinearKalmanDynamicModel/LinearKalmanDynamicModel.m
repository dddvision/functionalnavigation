classdef LinearKalmanDynamicModel < LinearKalmanDynamicModel.LinearKalmanDynamicModelConfig & DynamicModel
  
  properties (Constant=true,GetAccess=private)
    sixthIntMax=715827882.5;
    initialNumLogical=uint32(0);
    initialNumUint32=uint32(2);
    extensionNumLogical=uint32(0);
    extensionNumUint32=uint32(0);
    extensionBlockCost=0;
    rate=0;
    numExtension=uint32(0);
    extensionErrorText='This dynamic model has no extension blocks.';
  end
  
  properties (GetAccess=private,SetAccess=private)
    initialTime
    initialBlock
    xRef
  end
  
  methods (Access=public)
    function description=initialBlockDescription(this)
      description=struct('numLogical',this.initialNumLogical,'numUint32',this.initialNumUint32);
    end
  
    function description=extensionBlockDescription(this)
      description=struct('numLogical',this.extensionNumLogical,'numUint32',this.extensionNumUint32);
    end
    
    function rate=updateRate(this)
      rate=this.rate;
    end
  
    function this=LinearKalmanDynamicModel(initialTime,uri)
      this=this@DynamicModel(initialTime,uri);
      this.initialTime=initialTime;
      this.initialBlock=struct('logical',false(1,this.initialNumLogical),...
        'uint32',zeros(1,this.initialNumUint32,'uint32'));

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
    
    function pose=evaluate(this,t)
      pose=evaluate(this.xRef,t);
      [a,b]=domain(this.xRef);
      t(t>b)=b;
      z=initialBlock2deviation(this,this.initialBlock);
      for k=1:numel(t)
        pose(k).p(1) = pose(k).p(1) + ...
          this.positionOffset + this.positionRateOffset*(t(k)-this.initialTime) - ...
          this.positionDeviation*z(1) - this.positionRateDeviation*z(2)*(t(k)-this.initialTime);
      end
    end
   
    function tangentPose=tangent(this,t)
      tangentPose=tangent(this.xRef,t);
      [a,b]=domain(this.xRef);
      t(t>b)=b;
      z=initialBlock2deviation(this,this.initialBlock);
      for k=1:numel(t)
        tangentPose(k).p(1) = tangentPose(k).p(1) + ...
          this.positionOffset + this.positionRateOffset*(t(k)-this.initialTime) - ...
          this.positionDeviation*z(1) - this.positionRateDeviation*z(2)*(t(k)-this.initialTime);
        tangentPose(k).r(1) = tangentPose(k).r(1) + this.positionRateOffset - this.positionRateDeviation*z(2);
      end
    end
  end
  
  methods (Access=private)
    function z=initialBlock2deviation(this,initialBlock)
      z=double(initialBlock.uint32)/this.sixthIntMax-3;
    end
  end
end
