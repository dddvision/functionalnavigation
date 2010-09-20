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
         tom.DataContainer.pDescriptionList(name,cD);
         tom.DataContainer.pFactoryList(name,cF);
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
        if(isfield(tom.DataContainer.pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    function text=description(name)
      text='';
      if(tom.DataContainer.isConnected(name))
        dL=tom.DataContainer.pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    function obj=create(name)
      persistent singleton
      if(tom.DataContainer.isConnected(name))
        if(isempty(singleton))
          cF=tom.DataContainer.pFactoryList(name);
          obj=cF.(name)();
          assert(isa(obj,'tom.DataContainer'));
          singleton=obj;
        else
          obj=singleton;
        end
      else
        error('The requested component is not connected');
      end
    end
  end
  
  methods (Abstract=true,Access=public,Static=true)
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
