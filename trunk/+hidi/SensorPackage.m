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
    function this = SensorPackage()
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
    
    function obj = create(name, parameters)
      if(hidi.SensorPackage.isConnected(name))
        cF = hidi.SensorPackage.pFactoryList(name);
        obj = feval(cF(name), parameters);
        assert(isa(obj, 'hidi.SensorPackage'));
      else
        error('"%s" is not connected. Its static initializer must call connect.', name);
      end
    end
    
    function [packageName, parameters] = splitCompoundURI(uri)
      packageName = uri;
      parameters = '';
      if(~strncmp(packageName, 'hidi:', 5))
        error('Expected URI format: hidi:<packageName>[?<key0>=<value0>[;<key1>=<value1>]]');
      end
      packageName = packageName(6:end);
      delimeter = strfind(packageName, '?');
      if(isempty(delimeter))
        return;
      end
      parameters = packageName((delimeter+1):end);
      packageName = packageName(1:(delimeter-1));
    end
    
    function str = getParameter(parameters, key)
      str = '';
      if(isempty(key))
        return;
      end
      delimeter = strfind(parameters, [key, '=']);
      if(isempty(delimeter))
        return;
      end
      str = parameters((delimeter+numel(key)+1):end);
      if(~strcmp(key, 'uri'))
        delimeter = strfind(str, ';');
        if(~isempty(delimeter))
          str = str(1:(delimeter-1));
        end
      end
    end
    
    function value = getDoubleParameter(parameters, key)
      str = hidi.SensorPackage.getParameter(parameters, key);
      if(isempty(str))
        value = nan;
      else
        value = str2double(str);
        if(isnan(value))
          value = 0.0;
        end
      end
    end
  end
  
  methods (Access = public, Abstract = true, Static = true)
    initialize(name);
  end
    
  methods (Access = public)
    function refresh(this)
      persistent init accelerometerArray gyroscopeArray magnetometerArray altimeter gpsReceiver pedometer
      if(isempty(init))
        accelerometerArray = this.getAccelerometerArray();
        gyroscopeArray = this.getGyroscopeArray();
        magnetometerArray = this.getMagnetometerArray();
        altimeter = this.getAltimeter();
        gpsReceiver = this.getGPSReceiver();
        pedometer = this.getPedometer();
        init = true;
      end
      for n = 1:numel(accelerometerArray)
        accelerometerArray{n}.refresh();
      end
      for n = 1:numel(gyroscopeArray)
        gyroscopeArray{n}.refresh();
      end
      for n = 1:numel(magnetometerArray)
        magnetometerArray{n}.refresh();
      end
      for n = 1:numel(altimeter)
        altimeter{n}.refresh();
      end
      for n = 1:numel(gpsReceiver)
        gpsReceiver{n}.refresh();
      end
      for n = 1:numel(pedometer)
        pedometer{n}.refresh();
      end
    end
  end
  
  methods (Access = public, Abstract = true)
    sensor = getAccelerometerArray(this);
    sensor = getGyroscopeArray(this);
    sensor = getMagnetometerArray(this);
    sensor = getAltimeter(this);
    sensor = getGPSReceiver(this);
    sensor = getPedometer(this);
  end
end
