classdef SensorPackage < handle
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
    function this = SensorPackage(uri)
      if(nargin==0)
        uri = '';
      end
      assert(isa(uri, 'char'));
    end
    
    function connect(name, cD, cF)
      if(isa(cD, 'function_handle')&&...
         isa(cF, 'function_handle'))
         hidi.SensorPackage.pDescriptionList(name, cD);
         hidi.SensorPackage.pFactoryList(name, cF);
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
        if(isKey(hidi.SensorPackage.pFactoryList(name), name))
          flag = true;
        end
      end
    end
    
    function text = description(name)
      text = '';
      if(hidi.SensorPackage.isConnected(name))
        dL = hidi.SensorPackage.pDescriptionList(name);
        text = feval(dL(name));
      end
    end
    
    function obj = create(name, uri)
      if(hidi.SensorPackage.isConnected(name))
        cF = hidi.SensorPackage.pFactoryList(name);
        obj = feval(cF(name), uri);
        assert(isa(obj, 'hidi.SensorPackage'));
      else
        error('"%s" is not connected. Its static initializer must call connect.', name);
      end
    end
  end
  
  methods (Abstract = true, Access = public, Static = true)
    initialize(name);
  end
    
  methods (Access = public)
    function refresh(this)
      assert(isa(this, 'hidi.SensorPackage'));
    end
    
    function sensor = getAccelerometerArray(this)
      assert(isa(this, 'hidi.SensorPackage'));
      sensor = zeros(0, 1);
    end
      
    function sensor = getGyroscopeArray(this)
      assert(isa(this, 'hidi.SensorPackage'));
      sensor = zeros(0, 1);
    end
    
    function sensor = getMagnetometerArray(this)
      assert(isa(this, 'hidi.SensorPackage'));
      sensor = zeros(0, 1);
    end
    
    function sensor = getAltimeter(this)
      assert(isa(this, 'hidi.SensorPackage'));
      sensor = zeros(0, 1);
    end
    
    function sensor = getGPSReceiver(this)
      assert(isa(this, 'hidi.SensorPackage'));
      sensor = zeros(0, 1);
    end
  end
end
