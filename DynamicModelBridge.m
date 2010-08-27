classdef DynamicModelBridge < DynamicModel

  properties (SetAccess=private,GetAccess=private)
    c % class name
    h % handle to instantiated C++ object
  end
  
  methods (Access=protected,Static=true)
    function initialize(name)
      assert(isa(name,'char'));
      compileOnDemand(name);
      function text=componentDescription
        text='Getting static descriptions through the bridge is not yet implemented.';
      end
      function obj=componentFactory(initialTime,uri)
        obj=DynamicModelBridge(name,initialTime,uri);
      end        
      DynamicModel.connect(name,@componentDescription,@componentFactory);
    end

    function this=DynamicModelBridge(name,initialTime,uri)
      this=this@DynamicModel(initialTime,uri);
      assert(isa(name,'char'));
      assert(isa(initialTime,'WorldTime'));
      assert(isa(uri,'char'));
      compileOnDemand(name);
      this.c=[name,'.',name,'Bridge'];
      initialTime=double(initialTime); % workaround avoids array duplication
      this.h=feval(this.c,name,initialTime,uri);
    end
  end
    
  methods (Access=public,Static=false)
    function num=numInitialLogical(this)
      num=feval(this.c,this.h,'numInitialLogical');
    end
    
    function num=numInitialUint32(this)
       num=feval(this.c,this.h,'numInitialUint32');
    end
    
    function num=numExtensionLogical(this)
       num=feval(this.c,this.h,'numExtensionLogical');
    end
    
    function num=numExtensionUint32(this)
       num=feval(this.c,this.h,'numExtensionUint32');
    end
    
    function num=numExtensionBlocks(this)
       num=feval(this.c,this.h,'numExtensionBlocks');
    end
    
    function v=getInitialLogical(this,p)
      v=feval(this.c,this.h,'getInitialLogical',p);
    end
    
    function v=getInitialUint32(this,p)
      v=feval(this.c,this.h,'getInitialUint32',p);
    end
    
    function v=getExtensionLogical(this,b,p)
      v=feval(this.c,this.h,'getExtensionLogical',b,p);
    end
    
    function v=getExtensionUint32(this,b,p)
      v=feval(this.c,this.h,'getExtensionUint32',b,p);
    end
    
    function setInitialLogical(this,p,v)
      feval(this.c,this.h,'setInitialLogical',p,v);
    end
    
    function setInitialUint32(this,p,v)
      feval(this.c,this.h,'setInitialUint32',p,v);
    end
    
    function setExtensionLogical(this,b,p,v)
      feval(this.c,this.h,'setExtensionLogical',b,p,v);
    end
    
    function setExtensionUint32(this,b,p,v)
      feval(this.c,this.h,'setExtensionUint32',b,p,v);
    end

    function cost=computeInitialBlockCost(this)
      cost=feval(this.c,this.h,'computeInitialBlockCost');
    end

    function cost=computeExtensionBlockCost(this,b)
      cost=feval(this.c,this.h,'computeExtensionBlockCost',b);
    end
    
    function extend(this)
      feval(this.c,this.h,'extend');
    end
     
    function interval=domain(this)
      interval=feval(this.c,this.h,'domain');
    end
   
    function pose=evaluate(this,t)
      assert(isa(t,'WorldTime'));
      t=double(t); % workaround avoids array duplication
      pose(1,numel(t))=Pose; % workaround creates object externally
      pose=feval(this.c,this.h,'evaluate',pose,t);
    end
    
    function tangentPose=tangent(this,t)
      assert(isa(t,'WorldTime'));
      t=double(t); % workaround avoids array duplication
      tangentPose(1,numel(t))=TangentPose; % workaround creates object externally
      tangentPose=feval(this.c,this.h,'tangent',tangentPose,t);
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
