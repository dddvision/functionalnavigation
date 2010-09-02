classdef DynamicModel < tom.Trajectory
    
  methods (Access=private,Static=true)
    function dL=pDescriptionList(name,cD)
      persistent descriptionList
      if(nargin==2)
        descriptionList.(name)=cD;
      else
        dL=descriptionList;
      end
    end

    function fL=pFactoryList(name,cF)
      persistent factoryList
      if(nargin==2)
        factoryList.(name)=cF;
      else
        fL=factoryList;
      end
    end
  end
  
  methods (Access=protected,Static=true)
    function this=DynamicModel(initialTime,uri)
      assert(isa(initialTime,'double'));
      assert(isa(uri,'char'));
    end
    
    function connect(name,cD,cF)
      if(isa(cD,'function_handle')&&...
         isa(cF,'function_handle'))
         tom.DynamicModel.pDescriptionList(name,cD);
         tom.DynamicModel.pFactoryList(name,cF);
      end
    end
  end
      
  methods (Access=public,Static=true)
    function flag=isConnected(name)
      flag=false;
      if(exist([name,'.',name],'class'))
        feval([name,'.',name,'.initialize'],name); 
        if(isfield(tom.DynamicModel.pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    function text=description(name)
      text='';
      if(tom.DynamicModel.isConnected(name))
        dL=tom.DynamicModel.pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    function obj=factory(name,initialTime,uri)
      if(tom.DynamicModel.isConnected(name))
        cF=tom.DynamicModel.pFactoryList(name);
        obj=cF.(name)(initialTime,uri);
        assert(isa(obj,'tom.DynamicModel'));
      else
        error('The requested component is not connected');
      end
    end
  end
  
  methods (Abstract=true,Access=public,Static=true)
    initialize(name);
  end
  
  methods (Abstract=true,Access=public,Static=false)
    num=numInitialLogical(this);
    num=numInitialUint32(this);
    num=numExtensionLogical(this);
    num=numExtensionUint32(this);

    num=numExtensionBlocks(this);
    extend(this);
    
    v=getInitialLogical(this,p);
    v=getInitialUint32(this,p);
    v=getExtensionLogical(this,b,p);
    v=getExtensionUint32(this,b,p);
    
    setInitialLogical(this,p,v);
    setInitialUint32(this,p,v);
    setExtensionLogical(this,b,p,v);
    setExtensionUint32(this,b,p,v);

    cost=computeInitialBlockCost(this);
    cost=computeExtensionBlockCost(this,b);
  end
    
end
