classdef Optimizer < handle

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
    function this = Optimizer()
    end
    
    function connect(name, cD, cF)
      if(isa(cD, 'function_handle')&&...
         isa(cF, 'function_handle'))
         tom.Optimizer.pDescriptionList(name, cD);
         tom.Optimizer.pFactoryList(name, cF);
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
        if(isKey(tom.Optimizer.pFactoryList(name), name))
          flag = true;
        end
      end
    end
    
    function text = description(name)
      text = '';
      if(tom.Optimizer.isConnected(name))
        dL = tom.Optimizer.pDescriptionList(name);
        text = feval(dL(name));
      end
    end
    
    function obj = create(name)
      if(tom.Optimizer.isConnected(name))
        cF = tom.Optimizer.pFactoryList(name);
        obj = feval(cF(name));
        assert(isa(obj, 'tom.Optimizer'));
      else
        error('The requested component is not connected');
      end
    end
  end
  
  methods (Abstract = true, Access = public, Static = true)
    initialize(name);
  end
  
  methods (Abstract = true, Access = public)
    num = numInitialConditions(this);
    defineProblem(dynamicModel, measure, randomize);
    refreshProblem(this);
    num = numSolutions(this);
    xEst = getSolution(this, k);
    cEst = getCost(this, k);
    step(this);
  end
  
end
