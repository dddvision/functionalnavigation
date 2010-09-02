classdef Measure < tom.Sensor

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
    function this=Measure(uri)
      assert(isa(uri,'char'));
    end
    
    function connect(name,cD,cF)
      if(isa(cD,'function_handle')&&...
         isa(cF,'function_handle'))
         tom.Measure.pDescriptionList(name,cD);
         tom.Measure.pFactoryList(name,cF);
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
        if(isfield(tom.Measure.pFactoryList(name),name))
          flag=true;
        end
      end
    end
    
    function text=description(name)
      text='';
      if(tom.Measure.isConnected(name))
        dL=tom.Measure.pDescriptionList(name);
        text=dL.(name)();
      end
    end
    
    function obj=factory(name,uri)
      if(tom.Measure.isConnected(name))
        cF=tom.Measure.pFactoryList(name);
        obj=cF.(name)(uri);
        assert(isa(obj,'tom.Measure'));
      else
        error('The requested component is not connected');
      end
    end
  end
  
  methods (Abstract=true,Access=public,Static=true)
    initialize(name);
  end
  
  methods (Abstract=true,Access=public,Static=false)
    edgeList=findEdges(this,x,naSpan,nbSpan);
    cost=computeEdgeCost(this,x,graphEdge);
  end
  
end
