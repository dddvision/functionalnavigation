classdef SensorPackageBridge < hidi.SensorPackage
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
  end
  
  methods (Access = public, Static = true)
    function initialize(name)
      assert(isa(name, 'char'));
      compileOnDemand(name);
      className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];     
      mName = [className, 'Bridge'];
      function text = componentDescription
        text = feval(mName, uint32(0), 'SensorPackageDescription', name);
      end
      function obj = componentFactory(parameters)
        obj = hidi.SensorPackageBridge(name, parameters);
      end
      if(feval(mName, uint32(0), 'SensorPackageIsConnected', name))
        hidi.SensorPackage.connect(name, @componentDescription, @componentFactory);
      end
    end

    function this = SensorPackageBridge(name, parameters)
      if(nargin>0)
        assert(isa(name, 'char'));
        assert(isa(parameters, 'char'));
        compileOnDemand(name);
        className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];
        this.m = [className, 'Bridge'];
        feval(this.m, uint32(0), 'SensorPackageCreate', name, parameters);
      end
    end
  end
    
  methods (Access = public)    
    function sensor = getAccelerometerArray(this)
      h = feval(this.m, uint32(0), 'getAccelerometerArray');
      sensor = repmat(hidi.AccelerometerArrayBridge, numel(h), 1);
      for s = 1:numel(h)
        sensor(s) = hidi.AccelerometerArrayBridge(this.m, h(s));
      end
    end
    
    function sensor = getGyroscopeArray(this)
      h = feval(this.m, uint32(0), 'getGyroscopeArray');
      sensor = repmat(hidi.GyroscopeArrayBridge, numel(h), 1);
      for s = 1:numel(h)
        sensor(s) = hidi.GyroscopeArrayBridge(this.m, h(s));
      end
    end
    
    function sensor = getMagnetometerArray(this)
      h = feval(this.m, uint32(0), 'getMagnetometerArray');
      sensor = repmat(hidi.MagnetometerArrayBridge, numel(h), 1);
      for s = 1:numel(h)
        sensor(s) = hidi.MagnetometerArrayBridge(this.m, h(s));
      end
    end
    
    function sensor = getAltimeter(this)
      h = feval(this.m, uint32(0), 'getAltimeter');
      sensor = repmat(hidi.AltimeterBridge, numel(h), 1);
      for s = 1:numel(h)
        sensor(s) = hidi.AltimeterBridge(this.m, h(s));
      end
    end
    
    function sensor = getGPSReceiver(this)
      h = feval(this.m, uint32(0), 'getGPSReceiver');
      sensor = repmat(hidi.GPSReceiverBridge, numel(h), 1);
      for s = 1:numel(h)
        sensor(s) = hidi.GPSReceiverBridge(this.m, h(s));
      end
    end
    
    function refresh(this)
      feval(this.m, uint32(0), 'refresh');
    end
  end
end

function compileOnDemand(name)
  persistent tried
  if(~isempty(tried))
    return;
  end
  tried = true;
  bridge = mfilename('fullpath');
  bridgecpp = [bridge, '.cpp'];
  include1 = ['-I"', fileparts(bridge), '"'];
  include2 = ['-I"', fileparts(fileparts(bridge)), '"'];
  base = fullfile(['+', name], name);
  basecpp = [base, '.cpp'];
  cpp = which(basecpp);
  output = [cpp(1:(end-4)), 'Bridge'];
  if(exist(output, 'file'))
    delete([output, '.', mexext]);
  end
  mex(include1, include2, bridgecpp, cpp, '-output', output);
end
