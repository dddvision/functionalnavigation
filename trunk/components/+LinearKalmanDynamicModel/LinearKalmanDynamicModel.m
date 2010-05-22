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
    parameterErrorText='This dynamic model has no initial logical parameters.';
    extensionErrorText='This dynamic model has no extension blocks.';
  end
  
  properties (GetAccess=private,SetAccess=private)
    initialTime
    initialUint32
    xRef
  end
  
  methods (Access=public)
    function this=LinearKalmanDynamicModel(initialTime,uri)
      this=this@DynamicModel(initialTime,uri);
      this.initialTime=initialTime;
      this.initialUint32=zeros(1,this.initialNumUint32,'uint32');

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
    
    function rate=updateRate(this)
      rate=this.rate;
    end
        
    function num=numInitialLogical(this)
      num=this.initialNumLogical;
    end
    
    function num=numInitialUint32(this)
      num=this.initialNumUint32;      
    end
  
    function num=numExtensionLogical(this)
      num=this.extensionNumLogical;
    end
    
    function num=numExtensionUint32(this)
      num=this.extensionNumUint32;
    end

    function num=numExtensionBlocks(this)
      num=this.numExtension;
    end
    
    function v=getInitialLogical(this,p)
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      v=false(size(p));
      error(this.parameterErrorText);
    end

    function v=getInitialUint32(this,p)
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      v=this.initialUint32(p+1);
    end

    function v=getExtensionLogical(this,b,p)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      v=false(size(p));
      error(this.extensionErrorText);
    end

    function v=getExtensionUint32(this,b,p)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      v=zeros(size(p),'uint32');
      error(this.extensionErrorText);
    end

    function setInitialLogical(this,p,v)
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      assert(isa(v,'logical'));
      assert(numel(v)==1);
      error(this.parameterErrorText);
    end

    function setInitialUint32(this,p,v)
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      assert(isa(v,'uint32'));
      assert(numel(v)==1);
      assert(p<this.initialNumUint32);
      this.initialUint32(p+1)=v;
    end
    
    function setExtensionLogical(this,b,p,v)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      assert(isa(v,'logical'));
      assert(numel(v)==1);
      error(this.extensionErrorText);
    end
    
   function setExtensionUint32(this,b,p,v)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      assert(isa(p,'uint32'));
      assert(numel(p)==1);
      assert(isa(v,'uint32'));
      assert(numel(v)==1);
      error(this.extensionErrorText);
    end
    
    function cost=computeInitialBlockCost(this)
      z=initialBlock2deviation(this);
      cost=0.5*dot(z,z);
    end

    function cost=computeExtensionBlockCost(this,b)
      assert(isa(b,'uint32'));
      assert(numel(b)==1);
      cost=this.extensionBlockCost;
    end
    
    function extend(this,num)
      assert(isa(num,'uint32'));
      assert(numel(num)==1);
      error(this.extensionErrorText);
    end
     
    function interval=domain(this)
      interval=TimeInterval(this.initialTime,WorldTime(inf));
    end
    
    function pose=evaluate(this,t)
      pose=evaluate(this.xRef,t);
      interval=domain(this.xRef);
      t(t>interval.second)=interval.second;
      z=initialBlock2deviation(this);
      c1=this.positionOffset-this.positionDeviation*z(1);
      c2=this.positionRateOffset-this.positionRateDeviation*z(2);
      for k=1:numel(t)
        pose(k).p(1)=pose(k).p(1)+c1+c2*(t(k)-this.initialTime);
      end
    end
   
    function tangentPose=tangent(this,t)
      tangentPose=tangent(this.xRef,t);
      interval=domain(this.xRef);
      t(t>interval.second)=interval.second;
      z=initialBlock2deviation(this);
      c1=this.positionOffset-this.positionDeviation*z(1);
      c2=this.positionRateOffset-this.positionRateDeviation*z(2);
      for k=1:numel(t)
        tangentPose(k).p(1)=tangentPose(k).p(1)+c1+c2*(t(k)-this.initialTime);
        tangentPose(k).r(1)=tangentPose(k).r(1)+c2;
      end
    end
  end
  
  methods (Access=private)
    function z=initialBlock2deviation(this)
      z=double(this.initialUint32)/this.sixthIntMax-3;
    end
  end
  
end
