classdef DynamicModel < Trajectory
    
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
         DynamicModel.pDescriptionList(name,cD);
         DynamicModel.pFactoryList(name,cF);
      end
    end
  end
      
  methods (Access=public,Static=true)
    function flag=isConnected(name)
      flag=false;
      if(exist([name,'.',name],'class'))
        feval([name,'.',name,'.initialize'],name); 
        if(isfield(DynamicModel.pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    function text=description(name)
      text='';
      if(DynamicModel.isConnected(name))
        dL=DynamicModel.pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    function obj=factory(name,initialTime,uri)
      if(DynamicModel.isConnected(name))
        cF=DynamicModel.pFactoryList(name);
        obj=cF.(name)(initialTime,uri);
        assert(isa(obj,'DynamicModel'));
      else
        error('DynamicModel is not connected to the requested component');
      end
    end
  end
  
  methods (Abstract=true,Access=protected,Static=true)
    initialize(name);
  end
  
  methods (Abstract=true,Access=public,Static=false)
    num=numInitialLogical(this);
    num=numInitialUint32(this);
    num=numExtensionLogical(this);
    num=numExtensionUint32(this);

    num=numExtensionBlocks(this);
    
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
    
    extend(this);
  end
    
end
