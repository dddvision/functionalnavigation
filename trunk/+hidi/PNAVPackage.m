classdef PNAVPackage < handle
  
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
    function this = PNAVPackage(uri)
      if(nargin==0)
        uri = '';
      end
      assert(isa(uri, 'char'));
    end
    
    function connect(name, cD, cF)
      if(isa(cD, 'function_handle')&&...
         isa(cF, 'function_handle'))
         hidi.PNAVPackage.pDescriptionList(name, cD);
         hidi.PNAVPackage.pFactoryList(name, cF);
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
          fprintf('ERROR: %s', err.message);
        end
        if(isKey(hidi.PNAVPackage.pFactoryList(name), name))
          flag = true;
        end
      end
    end
    
    function text = description(name)
      text = '';
      if(hidi.PNAVPackage.isConnected(name))
        dL = hidi.PNAVPackage.pDescriptionList(name);
        text = feval(dL(name));
      end
    end
    
    function obj = create(name, uri)
      if(hidi.PNAVPackage.isConnected(name))
        cF = hidi.PNAVPackage.pFactoryList(name);
        obj = feval(cF(name), uri);
        assert(isa(obj, 'hidi.PNAVPackage'));
      else
        error('"%s" is not connected. Its static initializer must call connect.', name);
      end
    end
  end
  
  methods (Abstract = true, Access = public, Static = true)
    initialize(name);
  end
    
  methods (Abstract = true, Access = public)
    refresh(this);
    getAccelerometerArray(this);
    getGyroscopeArray(this);
    getMagnetometerArray(this);
    getAltimeter(this);
    getGPSReceiver(this);
  end
  
end
