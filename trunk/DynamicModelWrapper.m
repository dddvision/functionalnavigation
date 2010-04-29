classdef DynamicModelWrapper < DynamicModel

  properties (SetAccess=private,GetAccess=private)
    c % class name
    h % handle to instantiated C++ object
  end
  
  methods (Access=public)
    function this=DynamicModelWrapper(pkg,initialTime,uri)
      this=this@DynamicModel(initialTime,uri);
      this.c=pkg;
      this.h=feval(this.c,pkg,initialTime,uri);
    end

    function rate=updateRate(this)
      rate=feval(this.c,this.h,'updateRate');
    end
    
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
    
    function extend(this,num)
      feval(this.c,this.h,'extend',num);
    end
     
    function interval=domain(this)
      interval=feval(this.c,this.h,'domain');
    end
   
    function pose=evaluate(this,t)
      pose=feval(this.c,this.h,'evaluate',t);
    end
    
    function tangentPose=tangent(this,t)
      tangentPose=feval(this.c,this.h,'tangent',t);
    end
  end
  
end
