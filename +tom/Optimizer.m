classdef Optimizer < handle

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
    function this=Optimizer(dynamicModel,measure)
      assert(isa(dynamicModel,'tom.DynamicModel'));
      assert(isa(measure,'cell'));
      for m=1:numel(measure)
        assert(isa(measure{m},'tom.Measure'));
      end
    end
    
    function connect(name,cD,cF)
      if(isa(cD,'function_handle')&&...
         isa(cF,'function_handle'))
         tom.Optimizer.pDescriptionList(name,cD);
         tom.Optimizer.pFactoryList(name,cF);
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
        if(isfield(tom.Optimizer.pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    function text=description(name)
      text='';
      if(tom.Optimizer.isConnected(name))
        dL=tom.Optimizer.pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    function obj=factory(name,dynamicModel,measure)
      if(tom.Optimizer.isConnected(name))
        cF=tom.Optimizer.pFactoryList(name);
        obj=cF.(name)(dynamicModel,measure);
        assert(isa(obj,'tom.Optimizer'));
      else
        error('The requested component is not connected');
      end
    end
  end
  
  methods (Abstract=true,Access=public,Static=true)
    initialize(name);
  end
  
  methods (Abstract=true,Access=public,Static=false)
    num=numResults(this);
    xEst=getTrajectory(this,k);
    cEst=getCost(this,k);
    step(this);
  end
  
end
