classdef DynamicModelBridge < DynamicModel

  properties (SetAccess=private,GetAccess=private)
    m % mex name without extension
    h % handle to instantiated C++ object
  end
  
  methods (Access=protected,Static=true)
    function initialize(name)
      assert(isa(name,'char'));
      compileOnDemand(name);
      mName=[name,'.',name,'Bridge'];
      function text=componentDescription
        text=feval(mName,'DynamicModelDescription',name);
      end
      function obj=componentFactory(initialTime,uri)
        obj=DynamicModelBridge(name,initialTime,uri);
      end
      if(feval(mName,'DynamicModelIsConnected',name))
        DynamicModel.connect(name,@componentDescription,@componentFactory);
      end
    end

    function this=DynamicModelBridge(name,initialTime,uri)
      this=this@DynamicModel(initialTime,uri);
      assert(isa(name,'char'));
      assert(isa(initialTime,'WorldTime'));
      assert(isa(uri,'char'));
      compileOnDemand(name);
      this.m=[name,'.',name,'Bridge'];
      initialTime=double(initialTime); % workaround avoids array duplication
      this.h=feval(this.m,'DynamicModelFactory',name,initialTime,uri);
    end
  end
    
  methods (Access=public,Static=false)
    function num=numInitialLogical(this)
      num=feval(this.m,this.h,'numInitialLogical');
    end
    
    function num=numInitialUint32(this)
       num=feval(this.m,this.h,'numInitialUint32');
    end
    
    function num=numExtensionLogical(this)
       num=feval(this.m,this.h,'numExtensionLogical');
    end
    
    function num=numExtensionUint32(this)
       num=feval(this.m,this.h,'numExtensionUint32');
    end
    
    function num=numExtensionBlocks(this)
       num=feval(this.m,this.h,'numExtensionBlocks');
    end
    
    function v=getInitialLogical(this,p)
      v=feval(this.m,this.h,'getInitialLogical',p);
    end
    
    function v=getInitialUint32(this,p)
      v=feval(this.m,this.h,'getInitialUint32',p);
    end
    
    function v=getExtensionLogical(this,b,p)
      v=feval(this.m,this.h,'getExtensionLogical',b,p);
    end
    
    function v=getExtensionUint32(this,b,p)
      v=feval(this.m,this.h,'getExtensionUint32',b,p);
    end
    
    function setInitialLogical(this,p,v)
      feval(this.m,this.h,'setInitialLogical',p,v);
    end
    
    function setInitialUint32(this,p,v)
      feval(this.m,this.h,'setInitialUint32',p,v);
    end
    
    function setExtensionLogical(this,b,p,v)
      feval(this.m,this.h,'setExtensionLogical',b,p,v);
    end
    
    function setExtensionUint32(this,b,p,v)
      feval(this.m,this.h,'setExtensionUint32',b,p,v);
    end

    function cost=computeInitialBlockCost(this)
      cost=feval(this.m,this.h,'computeInitialBlockCost');
    end

    function cost=computeExtensionBlockCost(this,b)
      cost=feval(this.m,this.h,'computeExtensionBlockCost',b);
    end
    
    function extend(this)
      feval(this.m,this.h,'extend');
    end
     
    function interval=domain(this)
      interval=feval(this.m,this.h,'domain');
    end
   
    function pose=evaluate(this,t)
      assert(isa(t,'WorldTime'));
      t=double(t); % workaround avoids array duplication
      pose(1,numel(t))=Pose; % workaround creates object externally
      pose=feval(this.m,this.h,'evaluate',pose,t);
    end
    
    function tangentPose=tangent(this,t)
      assert(isa(t,'WorldTime'));
      t=double(t); % workaround avoids array duplication
      tangentPose(1,numel(t))=TangentPose; % workaround creates object externally
      tangentPose=feval(this.m,this.h,'tangent',tangentPose,t);
    end
  end
  
end

function compileOnDemand(name)
  base=fullfile(['+',name],name);
  if(~exist([base,'Bridge'],'file'))
    basecpp=[base,'.cpp'];
    cpp=which(basecpp);
    mex('-I"."','DynamicModelBridge.cpp',cpp,'-output',[cpp(1:(end-4)),'Bridge']);
  end
end
