classdef SensorPackageBridge < hidi.SensorPackage
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
  end
  
  methods (Access = public, Static = true)
    function mName = compile(name, varargin)
      persistent mNameMap
      if(isempty(mNameMap))
        mNameMap = containers.Map;
      end
      if(~isKey(mNameMap, name))
        mNameMap(name) = [name, '.', name(find(['.', name]=='.', 1, 'last'):end), 'Bridge'];
        bridge = mfilename('fullpath');
        arg{1} = ['-I"', fileparts(fileparts(bridge)), '"'];
        arg{2} = [bridge, '.cpp'];
        arg{3} = '-output';
        cpp = which([fullfile(['+', name], name), '.cpp']);
        arg{4} = [cpp(1:(end-4)), 'Bridge'];
        if(exist(arg{4}, 'file'))
          delete([arg{4}, '.', mexext]);
        end
        arg = cat(2, arg, varargin);
        fprintf('mex');
        fprintf(' %s', arg{:});
        hidi.newline();
        mex(arg{:});
      end
      mName = mNameMap(name);
    end
    
    function initialize(name, varargin)
      assert(isa(name, 'char'));   
      mName = hidi.SensorPackageBridge.compile(name, varargin{:});
      function text = componentDescription
        text = feval(mName, uint32(0), 'description', name);
      end
      function obj = componentFactory(parameters)
        obj = hidi.SensorPackageBridge(name, parameters);
      end
      if(feval(mName, uint32(0), 'isConnected', name))
        hidi.SensorPackage.connect(name, @componentDescription, @componentFactory);
      end
    end

    function this = SensorPackageBridge(name, parameters)
      if(nargin>0)
        assert(isa(name, 'char'));
        assert(isa(parameters, 'char'));
        this.m = [name, '.', name(find(['.', name]=='.', 1, 'last'):end), 'Bridge'];
        feval(this.m, uint32(0), 'create', name, parameters);
      end
    end
  end
    
  methods (Access = public) 
    function sensor = getAccelerometerArray(this)
      h = feval(this.m, uint32(0), 'getAccelerometerArray');
      sensor = {};
      for s = 1:numel(h)
        sensor{s} = hidi.AccelerometerArrayBridge(this.m, h(s)); %#ok grows in loop
      end
    end
    
    function sensor = getAltimeter(this)
      h = feval(this.m, uint32(0), 'getAltimeter');
      sensor = {};
      for s = 1:numel(h)
        sensor{s} = hidi.AltimeterBridge(this.m, h(s)); %#ok grows in loop
      end
    end
    
    function sensor = getCamera(this)
      h = feval(this.m, uint32(0), 'getCamera');
      sensor = {};
      for s = 1:numel(h)
        sensor{s} = hidi.CameraBridge(this.m, h(s)); %#ok grows in loop
      end
    end
    
    function sensor = getGPSReceiver(this)
      h = feval(this.m, uint32(0), 'getGPSReceiver');
      sensor = {};
      for s = 1:numel(h)
        sensor{s} = hidi.GPSReceiverBridge(this.m, h(s)); %#ok grows in loop
      end
    end
    
    function sensor = getGyroscopeArray(this)
      h = feval(this.m, uint32(0), 'getGyroscopeArray');
      sensor = {};
      for s = 1:numel(h)
        sensor{s} = hidi.GyroscopeArrayBridge(this.m, h(s)); %#ok grows in loop
      end
    end
    
    function sensor = getMagnetometerArray(this)
      h = feval(this.m, uint32(0), 'getMagnetometerArray');
      sensor = {};
      for s = 1:numel(h)
        sensor{s} = hidi.MagnetometerArrayBridge(this.m, h(s)); %#ok grows in loop
      end
    end
    
    function sensor = getPedometer(this)
      h = feval(this.m, uint32(0), 'getPedometer');
      sensor = {};
      for s = 1:numel(h)
        sensor{s} = hidi.PedometerBridge(this.m, h(s)); %#ok grows in loop
      end
    end
    
    function delete(this)
      feval(this.m, uint32(0), 'destroy');
    end
  end
end
