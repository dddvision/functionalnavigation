classdef PNAVPackageBridge < hidi.PNAVPackage
  properties (SetAccess = private, GetAccess = private)
    m % mex name without extension
    accelerometerArray
    gyroscopeArray
    magnetometerArray
    altimeter
    gpsReceiver
  end
  
  methods (Access = public, Static = true)
    function initialize(name)
      assert(isa(name, 'char'));
      compileOnDemand(name);
      className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];     
      mName = [className, 'Bridge'];
      function text = componentDescription
        text = feval(mName, 'PNAVPackageDescription', name);
      end
      function obj = componentFactory(uri)
        obj = hidi.PNAVPackageBridge(name, uri);
      end
      if(feval(mName, 'PNAVPackageIsConnected', name))
        hidi.PNAVPackage.connect(name, @componentDescription, @componentFactory);
      end
    end

    function this = PNAVPackageBridge(name, uri)
      if(nargin==0)
        uri = '';
      end
      this = this@hidi.PNAVPackage(uri);
      if(nargin>0)
        assert(isa(name, 'char'));
        assert(isa(uri, 'char'));
        compileOnDemand(name);
        className = [name, '.', name(find(['.', name]=='.', 1, 'last'):end)];
        this.m = [className, 'Bridge'];
        feval(this.m, 'PNAVPackageCreate', name, uri);
        this.accelerometerArray = hidi.AccelerometerArrayBridge(this.m);
        this.gyroscopeArray = hidi.GyroscopeArrayBridge(this.m);
        this.magnetometerArray = hidi.MagnetometerArrayBridge(this.m);
        this.altimeter = hidi.AltimeterBridge(this.m);
        this.gpsReceiver = hidi.GPSReceiverBridge(this.m);
      end
    end
  end
    
  methods (Access = public)    
    function sensor = getAccelerometerArray(this)
      sensor = this.accelerometerArray;
    end
    
    function sensor = getGyroscopeArray(this)
      sensor = this.gyroscopeArray;
    end
    
    function sensor = getMagnetometerArray(this)
      sensor = this.magnetometerArray;
    end
    
    function sensor = getAltimeter(this)
      sensor = this.altimeter;
    end
    
    function sensor = getGPSReceiver(this)
      sensor = this.gpsReceiver;
    end
    
    function refresh(this)
      feval(this.m, 'refresh');
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
  include2 = ['-I"', fileparts(which('hidi.WorldTime')), '"'];
  base = fullfile(['+', name], name);
  basecpp = [base, '.cpp'];
  cpp = which(basecpp);
  output = [cpp(1:(end-4)), 'Bridge'];
  if(exist(output, 'file'))
    delete([output, '.', mexext]);
  end
  mex(include1, include2, bridgecpp, cpp, '-output', output);
end
