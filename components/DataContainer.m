classdef DataContainer < handle
  
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
    function this=DataContainer
    end
    
    function connect(name,cD,cF)
      if(isa(cD,'function_handle')&&...
         isa(cF,'function_handle'))
         DataContainer.pDescriptionList(name,cD);
         DataContainer.pFactoryList(name,cF);
      end
    end
  end
      
  methods (Access=public,Static=true)
    function flag=isConnected(name)
      flag=false;
      if(exist([name,'.',name],'class'))
        try
          feval([name,'.',name,'.initialize'],name);
        catch err
          err.message;
        end  
        if(isfield(DataContainer.pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    function text=description(name)
      text='';
      if(DataContainer.isConnected(name))
        dL=DataContainer.pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    function obj=factory(name)
      persistent singleton
      if(DataContainer.isConnected(name))
        if(isempty(singleton))
          cF=DataContainer.pFactoryList(name);
          obj=cF.(name)();
          assert(isa(obj,'DataContainer'));
          singleton=obj;
        else
          obj=singleton;
        end
      else
        error('DataContainer is not connected to the requested component');
      end
    end
  end
  
  methods (Abstract=true,Access=protected,Static=true)
    initialize(name);
  end
  
  methods (Abstract=true,Access=public,Static=false)
    list=listSensors(this,type); 
    text=getSensorDescription(this,id);
    obj=getSensor(this,id);
    flag=hasReferenceTrajectory(this);
    x=getReferenceTrajectory(this);
  end
  
end
