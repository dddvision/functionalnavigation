classdef Measure < hidi.Sensor

  methods (Access = private, Static = true)
    function dL = pDescriptionList(name, cD)
      persistent descriptionList
      if(isempty(descriptionList))
        descriptionList = containers.Map;
      end
      if(nargin==2)
        descriptionList(name) = cD;
      else
        dL = descriptionList;
      end
    end

    function fL = pFactoryList(name, cF)
      persistent factoryList
      if(isempty(factoryList))
        factoryList = containers.Map;
      end
      if(nargin==2)
        factoryList(name) = cF;
      else
        fL = factoryList;
      end
    end
  end
  
  methods (Access = protected, Static = true)
    function this = Measure(initialTime, uri)
      this = this@hidi.Sensor();
      assert(isa(initialTime, 'double'));
      assert(isa(uri, 'char'));
    end
    
    function connect(name, cD, cF)
      if(isa(cD, 'function_handle')&&...
         isa(cF, 'function_handle'))
         tom.Measure.pDescriptionList(name, cD);
         tom.Measure.pFactoryList(name, cF);
      end
    end
  end
      
  methods (Access = public, Static = true)
    function flag = isConnected(name)
      flag = false;
      className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];
      if(exist(className, 'class'))
        try
          feval([className, '.initialize'], name);
        catch err
          err.message;
        end  
        if(isKey(tom.Measure.pFactoryList(name), name))
          flag = true;
        end
      end
    end
    
    function text = description(name)
      text = '';
      if(tom.Measure.isConnected(name))
        dL = tom.Measure.pDescriptionList(name);
        text = feval(dL(name));
      end
    end
    
    function obj = create(name, initialTime, uri)
      if(tom.Measure.isConnected(name))
        cF = tom.Measure.pFactoryList(name);
        obj = feval(cF(name), initialTime, uri);
        assert(isa(obj, 'tom.Measure'));
      else
        error('The requested component is not connected');
      end
    end
  end
  
  methods (Access = public, Abstract = true, Static = true)
    initialize(name);
  end
  
  methods (Access = public, Abstract = true)
    edgeList = findEdges(this, naMin, naMax, nbMin, nbMax);
    cost = computeEdgeCost(this, x, graphEdge);
  end
  
end
