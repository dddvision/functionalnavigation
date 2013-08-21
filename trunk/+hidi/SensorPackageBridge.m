classdef SensorPackageBridge < hidi.SensorPackage
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
  end
  
  methods (Access = public, Static = true)
    function initialize(name)
      assert(isa(name, 'char'));   
      mName = compileOnDemand(name);
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
        this.m = compileOnDemand(name);
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
  end
end

% Attempt once to compile on demand.
function mName = compileOnDemand(name)
  persistent mNameCache
  if(isempty(mNameCache))
    mNameCache = [name, '.', name(find(['.', name]=='.', 1, 'last'):end), 'Bridge'];
    bridge = mfilename('fullpath');
    arg{1} = ['-I"', fileparts(fileparts(bridge)), '"'];
    arg{2} = [bridge, '.cpp'];
    arg{3} = '-output';
    cpp = which([fullfile(['+', name], name), '.cpp']);
    arg{4} = [cpp(1:(end-4)), 'Bridge'];
    if(exist(arg{4}, 'file'))
      delete([arg{4}, '.', mexext]);
    end
    fprintf('mex');
    fprintf(' %s', arg{:});
    fprintf('\n');
    mex(arg{:});
  end
  mName = mNameCache;
end
